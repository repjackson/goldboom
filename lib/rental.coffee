Router.route '/rentals', -> @render 'rentals'
Router.route '/rental', -> @render 'rentals'
Router.route '/rental/:doc_id', -> @render 'rental_view'
Router.route '/rental/:doc_id/edit', -> @render 'rental_edit'


if Meteor.isClient
    Template.rentals.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'rental', ->
    Template.rental_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.rental_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
            
    Template.rental_owners.onCreated ->
        @autorun => Meteor.subscribe 'rental_owners', Router.current().params.doc_id
    Template.rental_permits.onCreated ->
        @autorun => Meteor.subscribe 'rental_permits', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'rental_rentals', Router.current().params.rental_code


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
                
                
                
    Template.rental_owners.helpers
        owners: ->
            rental =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if rental
                Meteor.users.find
                    owner:true
                    # roles:$in:['owner']
                    building_number:rental.building_number
                    rental_number:rental.rental_number

    Template.rental_residents.onCreated ->
        @autorun => Meteor.subscribe 'rental_residents', Router.current().params.doc_id
    Template.rental_residents.helpers
        rental_resident_docs: ->
            rental =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if rental
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:rental.building_number
                    rental_number:rental.rental_number




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
    
    Template.rental_orders.helpers
        rental_order_docs: ->
            Docs.find 
                model:'order'
                rental_id:Router.current().params.doc_id

    Template.rental_card.onCreated ->
        @autorun => Meteor.subscribe 'rental_residents', @data._id
        @autorun => Meteor.subscribe 'rental_owners', @data._id
        @autorun => Meteor.subscribe 'rental_permits', @data._id
        # @autorun => Meteor.subscribe 'rental_rentals', Router.current().params.rental_code

    Template.rental_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                rental_number:@rental_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                rental_number:@rental_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'rental', (rental_code)->
        Docs.find
            model:'rental'
            slug:rental_code


    Meteor.publish 'rental_rentals', (rental_code)->
        Docs.find
            model:'rental'
            rental_code:rental_code


    Meteor.publish 'rental_owners', (rental_id)->
        rental =
            Docs.findOne
                _id:rental_id
        if rental
            Meteor.users.find
                # roles:$in:['owner']
                owner:true
                building_number:rental.building_number
                rental_number:rental.rental_number

    Meteor.publish 'rental_residents', (rental_id)->
        rental =
            Docs.findOne
                _id:rental_id
        if rental
            Meteor.users.find
                # roles:$in:['resident']
                building_number:rental.building_number
                rental_number:rental.rental_number

    Meteor.publish 'rental_permits', (rental_id)->
        rental =
            Docs.findOne
                _id:rental_id
        Docs.find
            model: 'parking_permit'
            address_number:rental.building_number
    Meteor.publish 'user_key', (rental_id)->
        rental = Docs.findOne rental_id
        if rental
            Docs.find
                model:'key'
                building_number:rental.building_number
                rental_number:rental.rental_number