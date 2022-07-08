Template.nav.helpers
    is_connected: -> 
        # console.log Meteor.status().connected
        Meteor.status().connected
    unread_count: ->
        Docs.find(
            model:'log'
            read_user_ids:$nin:[Meteor.userId()]
        ).count()
Template.nav_item.helpers
    nav_item_class: (model)->
        # console.log model
        if Router.current().params.model is model then 'active' else ''
        
        
Template.nav.onRendered ->
    Meteor.setTimeout ->
        $('.menu .item')
            .popup()
    , 3000
    Meteor.setTimeout ->
        $('.ui.dropdown').dropdown()
    , 2000
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
    'mouseenter img': (e)->
        # console.log 'hi'
        $(e.currentTarget).closest('.image').addClass('pulse')
    'mouseleave img': (e)->
        # console.log 'hi'
        $(e.currentTarget).closest('.image').removeClass('pulse')
        
Template.nav_item.events 
    'click .go_route': -> 
        Session.set('model',@key)
        picked_tags.clear()
Template.nav.onCreated ->
    Session.setDefault 'limit', 20
    @autorun -> Meteor.subscribe 'me', ->
    # @autorun -> Meteor.subscribe 'all_users_min', ->
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
Template.layout.events
    'click .fly_down': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade down', 500)
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade left', 500)
    'click .fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.card').transition('fade right', 500)
    'click .zoom': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .flip': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.grid').transition('flip', 500)
        
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)


Router.route '/', (->
    @layout 'layout'
    @render 'home'
    ), name:'home'