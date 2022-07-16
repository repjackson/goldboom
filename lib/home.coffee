if Meteor.isClient 
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    Template.active_checkins.onCreated ->
        @autorun => Meteor.subscribe 'active_checkins', ->
    Template.active_checkins.helpers 
        active_checkin_docs: ->
            Docs.find {
                model:'checkin'
                active:true
            }, 
                sort:_timestamp:-1
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'latest_model_docs', 'log', ->
        @autorun => Meteor.subscribe 'checkedout_users_from_search', Session.get('current_search_user'), ->
    Template.active_checkins.events
        'click .checkout': ->
            Docs.update @_id,
                $set:
                    active:false
                    checkout_timestamp:Date.now()
    Template.home.events
        'click .pick_user': ->
            console.log @
            Docs.insert 
                model:'checkin'
                active:true
                resident_user_id:@_id
                resident_username:@username
            Session.set('current_search_user',null)
            $('.search_user').val('')
        'keyup .search_user': _.throttle((e,t)->
            search_user = $('.search_user').val().trim().toLowerCase()
            # if search_user.length > 1
            #     Session.set('current_search_user', search_user)
            Session.set('current_search_user', search_user)
            console.log Session.get('current_search_user')
            # picked_tags.push search_user
            # # $( "p" ).blur();
        , 500)
    
        'click .checkin': ->
            if Meteor.userId() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        checkedin:true
                        checkedin_timestamp:Date.now()
                Docs.insert 
                    model:'checkin'
                    status:'active'
                    active:true
                    building_number:Meteor.user().building_number
                    unit_number:Meteor.user().unit_number
            else 
                Router.go '/login'
                
        'click .checkout': ->
            if Meteor.userId() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        checkedin:false
                        checked_out_timestamp:Date.now()
                found = 
                    Docs.findOne 
                        model:'checkin'
                        _author_id:Meteor.userId()
                        active:true
                if found
                    Docs.update found._id,
                        $set:
                            status:'checked_out'
                            active:false
            else 
                Router.go '/login'
                
    Template.home.helpers
        checkedout_user_docs: ->
            match = {}
            if Session.get('current_search_user').length > 0
                match.username = {$regex:"#{Session.get('current_search_user')}", $options: 'i'}
            Meteor.users.find match
    
    Template.latest_activity.helpers
        activity_docs: ->
            Docs.find 
                model:'log'
            
    Template.latest_checkins.events 
        'click .delete_checkin': -> 
            if confirm 'delete checkin?'
                Docs.remove @_id
    Template.latest_checkins.helpers
        latest_checkin_docs: ->
            Docs.find {
                model:'checkin'
            }, 
                sort:
                    _timestamp:-1
    Template.latest_checkins.onCreated ->
        @autorun => Meteor.subscribe 'latest_model_docs','checkin', ->

if Meteor.isServer
    Meteor.publish 'checkedout_users_from_search', (username_search)->
        match = {}
        # match.checkedin = $ne:true
        if username_search.length > 0
            match.username = {$regex:"#{username_search}", $options: 'i'}
        Meteor.users.find match
            
    Meteor.publish 'latest_model_docs', (model)->
        Docs.find {
            model:model
        }, 
            sort:_timestamp:-1
            limit:10
            
    Meteor.publish 'active_checkins', ()->
        Docs.find {
            model:'checkin'
            active:true
        }
            
            
            