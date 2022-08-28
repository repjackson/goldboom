Router.route '/rental', -> @render 'rentals'
Router.route '/rentals', (->
    @layout 'layout'
    @render 'rentals'
    ), name:'rentals'
Router.route '/rental/:doc_id', (->
    @layout 'layout'
    @render 'rental_view'
    ), name:'rental_view'
Router.route '/rental/:doc_id/edit', (->
    @layout 'layout'
    @render 'rental_edit'
    ), name:'rental_edit'


if Meteor.isClient
    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'rental', ->
        @autorun => Meteor.subscribe 'model_docs', 'unit', ->
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
            
    Template.rentals.events
        'click .add_rental': ->
            new_id = 
                Docs.insert 
                    model:'rental'
            Router.go "/rental/#{new_id}/edit"
            
            
    Template.rentals.helpers
        rental_docs: ->
            Docs.find 
                model:'rental'
        unit_rental_docs: ->
            Docs.find 
                model:'unit'
                for_rent:true
                
                
    Template.rental_view.helpers
        rental: ->
            Docs.findOne
                model:'rental'
                slug: Router.current().params.rental_code

        rentals: ->
            Docs.find {
                model:'rental'
            }, sort: rental_number:1
                # rental_slug:Router.current().params.rental_code

    Template.rental_view.events
        'click .rent': ->
            Docs.insert 
                model:'order'
                parent_id:Router.current().params.doc_id
                rental_id:Router.current().params.doc_id
                order_type:'rental'
                active:true
            Docs.update @_id,
                $set:
                    available:false
        'keyup .rental_number': (e,t)->
            if e.which is 13
                rental_number = parseInt $('.rental_number').val().trim()
                rental_number = parseInt $('.rental_number').val()
                rental_label = $('.rental_label').val().trim()
                rental = Docs.findOne model:'rental'
                Docs.insert
                    model:'rental'
                    rental_number:rental_number
                    rental_number:rental.rental_number
                    rental_code:rental.slug

    Template.rental_orders.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'order', ->
    
    Template.rental_orders.events
        'click .return_rental': ->
            Docs.update @_id,
                $set:
                    active:false
                    return_timestamp:Date.now()
            Docs.update Router.current().params.doc_id, 
                $set:
                    available:true
                    returned_last_timestamp:Date.now()
        'click .return_active_rental': ->
            active_rental = 
                Docs.findOne 
                    model:'order'
                    active:true
            Docs.update active_rental._id,  
                $set:
                    active:false
                    return_timestamp:Date.now()
            Docs.update Router.current().params.doc_id, 
                $set:
                    available:true
                    returned_last_timestamp:Date.now()

    Template.rental_orders.helpers
        rental_order_docs: ->
            Docs.find {
                model:'order'
                rental_id:Router.current().params.doc_id
            },
                sort:
                    _timestamp:-1