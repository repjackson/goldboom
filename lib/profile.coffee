if Meteor.isClient
    Router.route '/user/:username', (->
        @layout 'layout'
        @render 'profile'
        ), name:'profile'

    Template.profile_nav_item.helpers
        profile_item_class: ->
            console.log @
            if Router.current().params.section is @section then 'big active' else ''
            

    Template.user_inbox.onCreated ->
        @autorun -> Meteor.subscribe 'unread_logs',->
    Template.user_inbox.events
        'click .mark_all_read': ->
            $('.ui.toast').toast('close')
            Meteor.call 'mark_unread_logs_read', ->
            
if Meteor.isServer
    Meteor.methods
        mark_unread_logs_read: ->
            Docs.update({
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
            },{
                $addToSet:
                    read_user_ids:Meteor.userId()
            },{multi:true})
            
if Meteor.isClient
    Template.user_inbox.helpers
        user_unread_log_docs: ->
            Docs.find 
                model:'log'
                
            
    
    Template.profile.onCreated ->
        # Meteor.call 'calc_user_points', Router.current().params.username, ->
    Template.profile.onRendered ->
        document.title = "profile";
        Meteor.call 'increment_profile_view', Router.current().params.username, ->
        Meteor.setTimeout ->
            $('.ui.accordion').accordion()
        , 2000
    # Template.profile.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1000
        
        
                
if Meteor.isClient
    Template.user_checkins.onCreated ->
        @autorun -> Meteor.subscribe 'user_checkins', Router.current().params.username, ->
    Template.user_checkins.helpers
        user_checkin_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                _author_id:user._id
                model:'checkin'
if Meteor.isServer 
    Meteor.publish 'user_checkins', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            _id:$in:user.favorite_ids
        }, 
            limit:5
            fields:
                title:1
                model:1
                image_id:1




if Meteor.isClient    
    Template.user_posts.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'post', Router.current().params.username, ->
    Template.user_comments.onCreated ->
        @autorun -> Meteor.subscribe 'user_model_docs', 'comment', Router.current().params.username, ->
        
    Template.user_comments.helpers
        user_comment_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'comment'
                _author_id:user._id
        
    Template.user_posts.helpers
        user_authored_post_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'post'
                _author_id:user._id
            }, 
                sort:_timestamp:-1
                limit:10
    Template.user_posts.events 
        
    Template.i.onRendered ->
        Meteor.setTimeout ->
            $('.image').popup()
        , 2000
    Template.profile.onRendered ->
        Meteor.setTimeout ->
            $('.button').popup()
            $('.avatar').popup()
        , 2000
    Template.nav.onRendered ->
        Meteor.setTimeout ->
            $('.item').popup()
        , 1000

    Template.profile.events

    Template.profile.helpers
        my_unread_log_docs: ->
            Docs.find 
                model:'log'
                read_user_ids:$nin:[Meteor.userId()]
        user_unread_log_docs: ->
            user = Meteor.users.findOne username:Router.current().params.username
            Docs.find 
                model:'log'
                read_user_ids:$nin:[user._id]
    Template.profile.helpers
        current_viewing_doc: ->
            if Meteor.user().current_viewing_doc_id
                Docs.findOne Meteor.user().current_viewing_doc_id

    Template.logout_other_clients_button.events
        'click .logout_other_clients': ->
            Meteor.logoutOtherClients()

    Template.logout_button.events
        'click .logout': (e,t)->
            # Meteor.call 'insert_log', 'logout', Session.get('current_userid'), ->
                
            Router.go '/login'
            $(e.currentTarget).closest('.grid').transition('slide left', 500)
            
            Meteor.logout()
            $('body').toast({
                title: "logged out"
                # message: 'Please see desk staff for key.'
                class : 'success'
                position:'bottom center'
                # className:
                #     toast: 'ui massive message'
                # displayTime: 5000
                transition:
                  showMethod   : 'zoom',
                  showDuration : 250,
                  hideMethod   : 'fade',
                  hideDuration : 250
                })
                
            
if Meteor.isServer
    Meteor.publish 'current_viewing_doc', (username)->
        user = Meteor.users.findOne username:username
        if user.current_viewing_doc_id
            Docs.find 
                _id:user.current_viewing_doc_id
    Meteor.publish 'user_groups_member', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'group'
            member_ids:$in:[user._id]
        },
            limit:10
            # fields:
            #     title:1
            #     model:1
            #     image_id:1
            #     member_ids:1
            #     points:1
            #     tags:1
            #     _author:1
            
    Meteor.publish 'user_model_docs', (model,username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:model
            _author_id:user._id
            published:true
        }, 
            limit:20
            sort:
                _timestamp:-1
            fields:
                title:1
                model:1
                image_id:1
                _author_id:1
                points:1
                views:1
                _timestamp:-1
                tags:1

if Meteor.isClient
    Template.profile.onCreated ->
        # @autorun => Meteor.subscribe 'user_orders', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'rental'
        # @autorun => Meteor.subscribe 'joint_transactions', Router.current().params.username
        @autorun => Meteor.subscribe 'user_deposts', Router.current().params.username, ->
        # @autorun => Meteor.subscribe 'model_docs', 'order', ->
        # @autorun => Meteor.subscribe 'model_docs', 'withdrawal'


    Template.profile.helpers
        owner_earnings: ->
            Docs.find
                model:'order'
                owner_username:Router.current().params.username
                complete:true
if Meteor.isClient
    Template.user_single_doc_ref_editor.onCreated ->
        @autorun => Meteor.subscribe 'type', @data.model

    Template.user_single_doc_ref_editor.events
        'click .select_choice': ->
            context = Template.currentData()
            current_user = Meteor.users.findOne Router.current().params._id
            Meteor.users.update current_user._id,
                $set: "#{context.key}": @slug

    Template.user_single_doc_ref_editor.helpers
        choices: ->
            Docs.find
                model:@model

        choice_class: ->
            context = Template.parentData()
            current_user = Meteor.users.findOne Router.current().params._id
            if current_user["#{context.key}"] and @slug is current_user["#{context.key}"] then 'grey' else ''



    Template.username_edit.events
        'click .change_username': (e,t)->
            new_username = t.$('.new_username').val()
            current_user = Meteor.users.findOne username:Router.current().params.username
            if new_username
                if confirm "change username from #{current_user.username} to #{new_username}?"
                    Meteor.call 'change_username', current_user._id, new_username, (err,res)->
                        if err
                            alert err
                        else
                            Router.go("/user/#{new_username}")




    Template.password_edit.events
        # 'click .change_password': (e, t) ->
        #     Accounts.changePassword $('#password').val(), $('#new_password').val(), (err, res) ->
        #         if err
        #             alert err.reason
        #         else
        #             alert 'password changed'
        #             # $('.amSuccess').html('<p>Password Changed</p>').fadeIn().delay('5000').fadeOut();

        'click .set_password': (e, t) ->
            new_password = $('#new_password').val()
            console.log 'new password', new_password
            current_user = Meteor.users.findOne username:Router.current().params.username
            Meteor.call 'set_password', current_user._id, new_password, (err,res)->
                if err 
                    alert err
                else if res
                    alert "password set to #{new_password}"
                    console.lgo 'res', res
                    
                    