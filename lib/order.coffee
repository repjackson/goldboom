if Meteor.isClient
    Template.mlayout.onCreated ->
        @autorun => @subscribe 'me'
    Template.orders.onCreated ->
        document.title = 'gr orders'
        
        Session.setDefault('current_search', null)
        Session.setDefault('dummy', false)
        Session.setDefault('is_loading', false)
        @autorun => @subscribe 'doc_by_id', Session.get('full_doc_id'), ->
        # @autorun => @subscribe 'agg_emotions',
        #     picked_tags.array()
        @autorun => @subscribe 'order_tag_results',
            picked_tags.array()
            
    Template.orders.onCreated ->
        @autorun => @subscribe 'model_docs', 'order', ->
        @autorun => @subscribe 'orders',
            picked_tags.array()
            # Session.get('dummy')
    
    
    
    Router.route '/order/:doc_id', (->
        @layout 'layout'
        @render 'order_view'
        ), name:'order_view'
    Router.route '/order/:doc_id/edit', (->
        @layout 'mlayout'
        @render 'order_edit'
        ), name:'order_edit'
    Router.route '/orders', (->
        @layout 'layout'
        @render 'orders'
        ), name:'orders'
    Template.orders.onCreated ->
        @autorun => Meteor.subscribe 'model_counter',('order'), ->
    Template.orders.helpers
        total_order_count: -> Counts.get('model_counter') 
        order_docs: ->
            Docs.find 
                model:'order'
    Template.orders.events 
        'click .new_order': ->
            new_id = 
                Docs.insert 
                    model:'order'
                    complete:false
            Router.go "/order/#{new_id}/edit"


    Template.user_points.onCreated ->
        @autorun => Meteor.subscribe 'model_docs','order', ->
    Template.user_points.helpers
        points_in_docs: ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            
            Docs.find 
                model:'order'
                target_id:user._id

        points_out_docs: ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find 
                model:'order'
                _author_id:user._id


    Template.order_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.order_view.onRendered ->
        # console.log @
        found_doc = Docs.findOne Router.current().params.doc_id


    
    
    Template.orders.events
        'click .select_search': ->
            picked_tags.push @name
            Session.set('full_doc_id', null)
    
            $('#search').val('')
            Session.set('current_search', null)
    
if Meteor.isClient
    Template.order_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_order_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        
    Template.order_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'user_info_min', ->
        Meteor.users.find {},
            fields: 
                username:1
                first_name:1
                last_name:1
                image_id:1
    Meteor.publish 'product_from_order_id', (order_id)->
        order = Docs.findOne order_id
        Docs.find 
            _id:order.product_id
if Meteor.isClient
    Template.order_edit.onCreated ->
        @autorun => Meteor.subscribe 'target_from_order_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'model_docs', 'rental', ->
        @autorun => Meteor.subscribe 'kiosk_document', ->
        @autorun => Meteor.subscribe 'kiosk_checkin', ->

if Meteor.isServer 
    Meteor.publish 'kiosk_checkin', ->
        if Meteor.isDevelopment
            kiosk = Docs.findOne 
                model:'kiosk'
                dev:true
        else
            kiosk = Docs.findOne 
                model:'kiosk'
        Docs.find kiosk.current_checkin_id
if Meteor.isClient
    Template.order_view.helpers
        _target: ->
            order = Docs.findOne Router.current().params.doc_id
            if order and order.target_id
                Meteor.users.findOne
                    _id: order.target_id

    Template.order_edit.helpers
        rental_items: ->
            Docs.find 
                model:'rental'
        # terms: ->
        #     Terms.find()
        _target: ->
            order = Docs.findOne Router.current().params.doc_id
            if order and order.target_id
                Meteor.users.findOne
                    _id: order.target_id
        members: ->
            order = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     order = Docs.findOne Router.current().params.doc_id
        #     order.amount*order.target_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            order = Docs.findOne Router.current().params.doc_id
            order.amount and order.target_id
        rental_class: ->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk
                checkin = Docs.findOne kiosk.current_checkin_id
                if checkin
                    if checkin.rental_id and @_id is checkin.rental_id then 'inverted' else ''
    Template.order_edit.events
        'click .pick_item': ->
            console.log @
            kiosk = Docs.findOne model:'kiosk'
            console.log kiosk
            checkin = Docs.findOne kiosk.current_checkin_id
            console.log checkin
            if checkin
                Docs.update checkin._id, 
                    $set:
                        rental_id:@_id
        'click .cancel': ->
            if confirm 'cancel?'
                Docs.remove @_id
                Router.go "/orders"
        'click .submit': ->
            Meteor.call 'send_order', @_id, =>
                $('body').toast({
                    title: "order sent"
                    # message: 'Please see desk staff for key.'
                    class : 'info'
                    icon:'remove'
                    position:'bottom right'
                    # className:
                    #     toast: 'ui massive message'
                    # displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
                Router.go "/order/#{@_id}"



if Meteor.isServer
    Meteor.publish 'target_from_doc_id', (order_id)->
        order = Docs.findOne order_id
        if order
            Meteor.users.find order.target_id
    Meteor.methods
        send_order: (order_id)->
            order = Docs.findOne order_id
            target = Meteor.users.findOne order.target_id
            orderer = Meteor.users.findOne order._author_id

            console.log 'sending order', order
            Meteor.call 'calc_user_stats', target._id, ->
            Meteor.call 'calc_user_stats', order._author_id, ->
    
            Docs.update order_id,
                $set:
                    submitted:true
                    published:true
                    submitted_timestamp:Date.now()
            return                    