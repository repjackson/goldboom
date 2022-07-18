Router.route '/spaces', -> @render 'spaces'
Router.route '/space', -> @render 'spaces'
Router.route '/space/:doc_id', -> @render 'space_view'
Router.route '/space/:doc_id/edit', -> @render 'space_edit'


if Meteor.isClient
    Template.spaces.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'space', ->
    Template.space_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.space_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
            
    Template.space_owners.onCreated ->
        @autorun => Meteor.subscribe 'space_owners', Router.current().params.doc_id
    Template.space_permits.onCreated ->
        @autorun => Meteor.subscribe 'space_permits', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'space_spaces', Router.current().params.space_code


    Template.spaces.events
        'click .add_space': ->
            new_id = 
                Docs.insert 
                    model:'space'
            Router.go "/space/#{new_id}/edit"
            
            
    Template.spaces.helpers
        space_docs: ->
            Docs.find 
                model:'space'
                
                
                
    Template.space_owners.helpers
        owners: ->
            space =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if space
                Meteor.users.find
                    owner:true
                    # roles:$in:['owner']
                    building_number:space.building_number
                    space_number:space.space_number

    Template.space_residents.onCreated ->
        @autorun => Meteor.subscribe 'space_residents', Router.current().params.doc_id
    Template.space_residents.helpers
        space_resident_docs: ->
            space =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if space
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:space.building_number
                    space_number:space.space_number


    Template.space_permits.helpers
        permits: ->
            space =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if space
                Docs.find
                    model: 'parking_permit'
                    address_number:space.building_number


    Template.space_view.helpers
        space: ->
            Docs.findOne
                model:'space'
                slug: Router.current().params.space_code

        spaces: ->
            Docs.find {
                model:'space'
            }, sort: space_number:1
                # space_slug:Router.current().params.space_code

    Template.space_view.events
        'keyup .space_number': (e,t)->
            if e.which is 13
                space_number = parseInt $('.space_number').val().trim()
                space_number = parseInt $('.space_number').val()
                space_label = $('.space_label').val().trim()
                space = Docs.findOne model:'space'
                Docs.insert
                    model:'space'
                    space_number:space_number
                    space_number:space.space_number
                    space_code:space.slug



    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'space_key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'space_key_access'
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
                    model:'space_key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
            else
                alert 'wrong code'










    Template.space_card.onCreated ->
        @autorun => Meteor.subscribe 'space_residents', @data._id
        @autorun => Meteor.subscribe 'space_owners', @data._id
        @autorun => Meteor.subscribe 'space_permits', @data._id
        # @autorun => Meteor.subscribe 'space_spaces', Router.current().params.space_code

    Template.space_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                space_number:@space_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                space_number:@space_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'space', (space_code)->
        Docs.find
            model:'space'
            slug:space_code


    Meteor.publish 'space_spaces', (space_code)->
        Docs.find
            model:'space'
            space_code:space_code


    Meteor.publish 'space_owners', (space_id)->
        space =
            Docs.findOne
                _id:space_id
        if space
            Meteor.users.find
                # roles:$in:['owner']
                owner:true
                building_number:space.building_number
                space_number:space.space_number

    Meteor.publish 'space_residents', (space_id)->
        space =
            Docs.findOne
                _id:space_id
        if space
            Meteor.users.find
                # roles:$in:['resident']
                building_number:space.building_number
                space_number:space.space_number
