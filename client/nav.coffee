Template.nav.helpers
    is_connected: -> 
        Meteor.status().connected
    unread_count: ->
        Docs.find(
            model:'log'
            read_user_ids:$nin:[Meteor.userId()]
        ).count()
Template.nav_item.helpers
    nav_item_class: (model)->
        if Router.current().params.model is model then 'active' else ''
        
        
Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
    , 3000
Template.home.onRendered ->
    Meteor.setTimeout ->
        $('.ui.accordion').accordion('open')
    , 3000
    Meteor.setTimeout ->
        $('.ui.left.sidebar')
            .sidebar({
                context: $('.bottom.segment')
                transition:'push'
                mobileTransition:'push'
                exclusive:true
                duration:200
                scrollLock:true
            })
            .sidebar('attach events', '.toggle_leftbar')
    , 6000
        

Template.role_switcher.events
    'click .switch_role': ->
        Meteor.users.update Meteor.userId(), 
            $set:
                current_role: @valueOf()
Template.nav.events
    'click .reconnect': -> Meteor.reconnect()
    'mouseenter .item': (e)->
        $(e.currentTarget).closest('.item').addClass('pulse')
    'mouseleave .item': (e)->
        $(e.currentTarget).closest('.item').removeClass('pulse')
    'click .toggle_darkmode': ->
        if Meteor.user()
            Meteor.users.update Meteor.userId(),
                $set:
                    darkmode:!Meteor.user().darkmode
        else 
            Session.set('darkmode',!Session.get('darkmode'))
        
Template.nav_item.events 
    'click .go_route': -> 
        Session.set('model',@key)
        picked_tags.clear()
Template.home.onCreated ->
    @autorun -> Meteor.subscribe 'active_checkins', ->
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    
    @autorun -> Meteor.subscribe 'me', ->
    # @autorun -> Meteor.subscribe 'all_users_min', ->
    @autorun -> Meteor.subscribe 'model_docs','stats', ->
    # @autorun -> Meteor.subscribe 'model_docs','group', ->
    @autorun -> Meteor.subscribe 'unread_logs', ->
    @autorun -> Meteor.subscribe 'staff_users', ->


Template.footer_chat.onCreated ->
    @autorun -> Meteor.subscribe 'model_docs','chat_message', ->
Template.footer_chat.helpers
    chat_messages: ->
        Docs.find {
            model:'chat_message'
        }, sort:_timestamp:-1
Template.footer_chat.events
    'click  .remove_message': (e)->
        if confirm "delete message? can't be undone"
            Docs.remove @_id
    'keyup .new_footer_chat_message': (e)->
        if e.which is 13
            val = $('.new_footer_chat_message').val()
            new_message = 
                Docs.insert 
                    model:'chat_message'
                    body:val
            val = $('.new_footer_chat_message').val('')
                
Template.nav.events
    'click .clear_read': ->
        $('.ui.toast').toast('close')
        Meteor.call 'mark_unread_logs_read', ->

    # 'click .add_doc': ->
    #     new_id = 
    #         Docs.insert {model:Session.get('model')}
    #     Router.go "/doc/#{new_id}/edit"

Template.nav.events
    'click .item': (e,t)-> $(e.currentTarget).closest('.item').transition('jiggle', 1000)
Template.nav_item.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('jiggle', 1000)
