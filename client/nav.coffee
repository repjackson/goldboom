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
    # Meteor.setTimeout ->
    #     $('.ui.left.sidebar')
    #         .sidebar({
    #             context: $('.bottom.segment')
    #             transition:'push'
    #             mobileTransition:'push'
    #             exclusive:true
    #             duration:200
    #             scrollLock:true
    #         })
    #         .sidebar('attach events', '.toggle_leftbar')
    # , 4000
        

Template.nav.events
    'click .reconnect': -> Meteor.reconnect()
    'mouseenter .item': (e)->
        $(e.currentTarget).closest('.item').addClass('pulse')
    'mouseleave .item': (e)->
        $(e.currentTarget).closest('.item').removeClass('pulse')
    'click .toggle_darkmode': ->
        Meteor.users.update Meteor.userId(),
            $set:
                darkmode:!Meteor.user().darkmode
        
Template.nav_item.events 
    'click .go_route': -> 
        Session.set('model',@key)
        picked_tags.clear()
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me', ->
    # @autorun -> Meteor.subscribe 'all_users_min', ->
    @autorun -> Meteor.subscribe 'model_docs','stats', ->
    # @autorun -> Meteor.subscribe 'model_docs','group', ->
    @autorun -> Meteor.subscribe 'unread_logs', ->


Template.nav.events
    'click .clear_read': ->
        $('.ui.toast').toast('close')
        Meteor.call 'mark_unread_logs_read', ->

    # 'click .add_doc': ->
    #     new_id = 
    #         Docs.insert {model:Session.get('model')}
    #     Router.go "/doc/#{new_id}/edit"

Template.nav.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('bounce', 1000)
Template.nav_item.events
    'click .tada': (e,t)-> $(e.currentTarget).closest('.icon').transition('bounce', 1000)
