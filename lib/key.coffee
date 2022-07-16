Router.route '/keys', -> @render 'keys'
Router.route '/key', -> @render 'keys'
Router.route '/key/:doc_id', -> @render 'key_view'
Router.route '/key/:doc_id/edit', -> @render 'key_edit'


if Meteor.isClient
    Template.keys.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'key', ->
    Template.key_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.key_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
            
    Template.key_owners.onCreated ->
        @autorun => Meteor.subscribe 'key_owners', Router.current().params.doc_id
    Template.key_permits.onCreated ->
        @autorun => Meteor.subscribe 'key_permits', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'key_keys', Router.current().params.key_code


    Template.keys.events
        'click .add_key': ->
            new_id = 
                Docs.insert 
                    model:'key'
            Router.go "/key/#{new_id}/edit"
            
            
    Template.keys.helpers
        key_docs: ->
            Docs.find 
                model:'key'
                
                
    Template.unit_keys.events 
        'click .add_unit_key': ->
            new_id = 
                Docs.insert 
                    model:'key'
                    unit_number:@unit_number
                    building_number:@building_number
                    submitted:false
                    status:'draft'
            Router.go "/key/#{new_id}/edit"

                
    Template.key_owners.helpers
        owners: ->
            key =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if key
                Meteor.users.find
                    owner:true
                    # roles:$in:['owner']
                    building_number:key.building_number
                    key_number:key.key_number

    Template.key_residents.onCreated ->
        @autorun => Meteor.subscribe 'key_residents', Router.current().params.doc_id
    Template.key_residents.helpers
        key_resident_docs: ->
            key =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if key
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:key.building_number
                    key_number:key.key_number


    Template.key_permits.helpers
        permits: ->
            key =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if key
                Docs.find
                    model: 'parking_permit'
                    address_number:key.building_number


    Template.key_view.helpers
        key: ->
            Docs.findOne
                model:'key'
                slug: Router.current().params.key_code

        keys: ->
            Docs.find {
                model:'key'
            }, sort: key_number:1
                # key_slug:Router.current().params.key_code

    Template.key_view.events
        'keyup .key_number': (e,t)->
            if e.which is 13
                key_number = parseInt $('.key_number').val().trim()
                key_number = parseInt $('.key_number').val()
                key_label = $('.key_label').val().trim()
                key = Docs.findOne model:'key'
                Docs.insert
                    model:'key'
                    key_number:key_number
                    key_number:key.key_number
                    key_code:key.slug



    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'key_key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'key_key_access'
                key_id:Docs.findOne(model:'key')._id
            }, sort:_timestamp:-1
    Template.user_key.events
        'click .view_code': ->
            access = prompt 'admin code'
            if access is '2959'
                Session.set 'viewing_code', true
                Meteor.setTimeout ->
                    Session.set 'viewing_code', false
                , 5000
                new_id = Docs.insert
                    model:'key_key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
            else
                alert 'wrong code'










    Template.key_card.onCreated ->
        @autorun => Meteor.subscribe 'key_residents', @data._id
        @autorun => Meteor.subscribe 'key_owners', @data._id
        @autorun => Meteor.subscribe 'key_permits', @data._id
        # @autorun => Meteor.subscribe 'key_keys', Router.current().params.key_code

    Template.key_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                key_number:@key_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                key_number:@key_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'key', (key_code)->
        Docs.find
            model:'key'
            slug:key_code


    Meteor.publish 'key_keys', (key_code)->
        Docs.find
            model:'key'
            key_code:key_code


    Meteor.publish 'key_owners', (key_id)->
        key =
            Docs.findOne
                _id:key_id
        if key
            Meteor.users.find
                # roles:$in:['owner']
                owner:true
                building_number:key.building_number
                key_number:key.key_number

    Meteor.publish 'key_residents', (key_id)->
        key =
            Docs.findOne
                _id:key_id
        if key
            Meteor.users.find
                # roles:$in:['resident']
                building_number:key.building_number
                key_number:key.key_number

    Meteor.publish 'key_permits', (key_id)->
        key =
            Docs.findOne
                _id:key_id
        Docs.find
            model: 'parking_permit'
            address_number:key.building_number
    Meteor.publish 'user_key', (key_id)->
        key = Docs.findOne key_id
        if key
            Docs.find
                model:'key'
                building_number:key.building_number
                key_number:key.key_number