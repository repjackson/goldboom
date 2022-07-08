if Meteor.isClient 
    Router.route '/checkins', (->
        @layout 'layout'
        @render 'checkins'
        ), name:'checkins'
        
    Template.checkins.onCreated ->
        @autorun => Meteor.subscribe 'model_counter','checkin', ->
        @autorun => Meteor.subscribe 'model_docs','checkin', ->
    Template.checkins.events
        'click .checkin': ->
            new_id = 
                Docs.insert 
                    model:'checkin'
            
    Template.checkins.helpers
        checkin_docs: ->
            Docs.find {
                model:'checkin'
            }, 
                sort:
                    _timestamp:-1
                limit:20