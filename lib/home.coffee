if Meteor.isClient 
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'latest_model_docs', 'log', ->
    Template.home.events 
        'click .checkin': ->
            if Meteor.userId() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        checked_in:true
                        checked_in_timestamp:Date.now()
                Docs.insert 
                    model:'checkin'
                    status:'active'
                    active:true
            else 
                Router.go '/login'
                
        'click .checkout': ->
            if Meteor.userId() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        checked_in:false
                        checked_out_timestamp:Date.now()
                found = 
                    Docs.findOne 
                        model:'checkin'
                        _author_id:Meteor.userId()
                        active:true
                if found
                    Docs.update found._id,
                        $set:
                            status:'checked_out'
                            active:false
            else 
                Router.go '/login'
                
                
    Template.latest_activity.helpers
        activity_docs: ->
            Docs.find 
                model:'log'
            
    Template.latest_checkins.helpers
        latest_checkin_docs: ->
            Docs.find 
                model:'checkin'
            
    Template.latest_checkins.onCreated ->
        @autorun => Meteor.subscribe 'latest_model_docs','checkin', ->

if Meteor.isServer
    Meteor.publish 'latest_model_docs', (model)->
        Docs.find {
            model:model
        }, 
            sort:_timestamp:-1
            limit:10