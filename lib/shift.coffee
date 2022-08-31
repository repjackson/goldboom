if Meteor.isClient
    Template.shifts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift', ->
    Template.shifts.helpers 
        shift_docs: ->
            Docs.find {
                model:'shift'
            }, sort: _timestamp:-1
        staff_users: ->
            Meteor.users.find {
                is_staff:true
            }, sort: username:-1
        is_assigned: ->
            @staff_username is Meteor.user().username
    Template.shifts.events 
        'click .add_shift': ->
            Docs.insert
                model:'shift'
                taken:false
                
        'click .take_shift': ->
            Docs.update @_id,
                $set:
                    taken:true 
                    staff_username:Meteor.user().username
                    staff_id:Meteor.userId()
