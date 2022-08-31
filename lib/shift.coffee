if Meteor.isClient
    Template.shifts.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'shift', ->
    Template.shift_day_item.helpers
        morning_shift: ->
            Docs.findOne
                model:'shift'
                shift_type:'morning'    
        afternoon_shift: ->
            Docs.findOne
                model:'shift'
                shift_type:'morning'    
        evening_shift: ->
            console.log @valueOf()
            Docs.findOne
                model:'shift'
                date:@valuOf()
                shift_type:'morning'    
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
        upcoming_days: ->
            [
                moment().add(1,'days').format("MM-DD-YY")
                moment().add(2,'days').format("MM-DD-YY")
                moment().add(3,'days').format("MM-DD-YY")
                moment().add(4,'days').format("MM-DD-YY")
                moment().add(5,'days').format("MM-DD-YY")
                moment().add(6,'days').format("MM-DD-YY")
                moment().add(7,'days').format("MM-DD-YY")
            ]

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
