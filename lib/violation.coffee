Router.route '/violations', -> @render 'violations'
Router.route '/violation', -> @render 'violations'
Router.route '/violation/:doc_id', -> @render 'violation_view'
Router.route '/violation/:doc_id/edit', -> @render 'violation_edit'


if Meteor.isClient
    Template.violations.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'violation', ->
    Template.violation_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.violation_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
            
    Template.violation_owners.onCreated ->
        @autorun => Meteor.subscribe 'violation_owners', Router.current().params.doc_id
    Template.violation_permits.onCreated ->
        @autorun => Meteor.subscribe 'violation_permits', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'violation_violations', Router.current().params.violation_code


    Template.violations.events
        'click .add_violation': ->
            new_id = 
                Docs.insert 
                    model:'violation'
            Router.go "/violation/#{new_id}/edit"
            
            
    Template.violations.helpers
        violation_docs: ->
            Docs.find 
                model:'violation'
                
                
    Template.unit_violations.events 
        'click .add_unit_violation': ->
            new_id = 
                Docs.insert 
                    model:'violation'
                    unit_number:@unit_number
                    building_number:@building_number
                    submitted:false
                    status:'draft'
            Router.go "/violation/#{new_id}/edit"

                
    Template.violation_owners.helpers
        owners: ->
            violation =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if violation
                Meteor.users.find
                    owner:true
                    # roles:$in:['owner']
                    building_number:violation.building_number
                    violation_number:violation.violation_number

    Template.violation_residents.onCreated ->
        @autorun => Meteor.subscribe 'violation_residents', Router.current().params.doc_id
    Template.violation_residents.helpers
        violation_resident_docs: ->
            violation =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if violation
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:violation.building_number
                    violation_number:violation.violation_number


    Template.violation_permits.helpers
        permits: ->
            violation =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if violation
                Docs.find
                    model: 'parking_permit'
                    address_number:violation.building_number


    Template.violation_view.helpers
        violation: ->
            Docs.findOne
                model:'violation'
                slug: Router.current().params.violation_code

        violations: ->
            Docs.find {
                model:'violation'
            }, sort: violation_number:1
                # violation_slug:Router.current().params.violation_code

    Template.violation_view.events
        'keyup .violation_number': (e,t)->
            if e.which is 13
                violation_number = parseInt $('.violation_number').val().trim()
                violation_number = parseInt $('.violation_number').val()
                violation_label = $('.violation_label').val().trim()
                violation = Docs.findOne model:'violation'
                Docs.insert
                    model:'violation'
                    violation_number:violation_number
                    violation_number:violation.violation_number
                    violation_code:violation.slug



    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'violation_key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'violation_key_access'
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
                    model:'violation_key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
            else
                alert 'wrong code'










    Template.violation_card.onCreated ->
        @autorun => Meteor.subscribe 'violation_residents', @data._id
        @autorun => Meteor.subscribe 'violation_owners', @data._id
        @autorun => Meteor.subscribe 'violation_permits', @data._id
        # @autorun => Meteor.subscribe 'violation_violations', Router.current().params.violation_code

    Template.violation_card.helpers
        owners: ->
            Meteor.users.find
                roles:$in:['owner']
                building_number:@building_number
                violation_number:@violation_number

        residents: ->
            Meteor.users.find
                roles:$in:['resident','owner']
                owner:$ne:true
                building_number:@building_number
                violation_number:@violation_number

        permits: ->
            Docs.find
                model: 'parking_permit'
                address_number:@building_number






if Meteor.isServer
    Meteor.publish 'violation', (violation_code)->
        Docs.find
            model:'violation'
            slug:violation_code


    Meteor.publish 'violation_violations', (violation_code)->
        Docs.find
            model:'violation'
            violation_code:violation_code


    Meteor.publish 'violation_owners', (violation_id)->
        violation =
            Docs.findOne
                _id:violation_id
        if violation
            Meteor.users.find
                # roles:$in:['owner']
                owner:true
                building_number:violation.building_number
                violation_number:violation.violation_number

    Meteor.publish 'violation_residents', (violation_id)->
        violation =
            Docs.findOne
                _id:violation_id
        if violation
            Meteor.users.find
                # roles:$in:['resident']
                building_number:violation.building_number
                violation_number:violation.violation_number

    Meteor.publish 'violation_permits', (violation_id)->
        violation =
            Docs.findOne
                _id:violation_id
        Docs.find
            model: 'parking_permit'
            address_number:violation.building_number
    Meteor.publish 'user_key', (violation_id)->
        violation = Docs.findOne violation_id
        if violation
            Docs.find
                model:'key'
                building_number:violation.building_number
                violation_number:violation.violation_number