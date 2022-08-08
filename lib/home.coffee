if Meteor.isClient 
    Router.route '/', (->
        @layout 'layout'
        @render 'home'
        ), name:'home'
    Template.active_checkins.onCreated ->
        @autorun => Meteor.subscribe 'active_checkins', ->
    Template.active_checkins.events
        'click .checkout': ->
            Docs.update @_id,
                $set:
                    active:false
                    checkout_timestamp:Date.now()
            Meteor.users.update @resident_user_id,
                $set:
                    checked_in:false
    Template.active_checkins.helpers 
        active_checkin_docs: ->
            Docs.find {
                model:'checkin'
                active:true
            }, 
                sort:_timestamp:-1
                
                
    Template.latest_rentals.onCreated ->
        @autorun => Meteor.subscribe 'latest_rentals', ->

    Template.latest_notes.onCreated ->
        @autorun => Meteor.subscribe 'latest_notes', ->
    Template.latest_notes.helpers 
        latest_note_docs: ->
            Docs.find {
                model:'post'
            }, 
                sort:_timestamp:-1
                

    Template.latest_requests.onCreated ->
        @autorun => Meteor.subscribe 'latest_requests', ->
    Template.latest_requests.helpers 
        kiosk_task_docs: ->
            Docs.find {
                model:'task'
            }, 
                sort:_timestamp:-1
                


if Meteor.isServer 
    Meteor.publish 'latest_requests', ->
        Docs.find {
            model:'task'
        },
            sort:_timestamp:-1
            limit:20
    Meteor.publish 'latest_notes', ->
        Docs.find {
            model:'post'
        },
            sort:_timestamp:-1
            limit:20
    Meteor.publish 'latest_rentals', ->
        Docs.find {
            model:'rental'
        },
            sort:_timestamp:-1
            limit:20
    Meteor.publish 'home_guests', ->
        Docs.find {
            model:'guest'
        }, 
            limit:20
            sort:_timestamp:-1
    
if Meteor.isClient 
    Template.home.onCreated ->
        @autorun => Meteor.subscribe 'latest_model_docs', 'log', ->
        @autorun => Meteor.subscribe 'home_guests', ->
        @autorun => Meteor.subscribe 'user_min', Session.get('current_search_user'), ->
    
if Meteor.isServer
    Meteor.publish 'user_min', ->
        Meteor.users.find {},
            fields:
                username:1
                first_name:1
                last_name:1
    
if Meteor.isClient
    Template.latest_rentals.helpers
        rental_item_docs: ->
            Docs.find 
                model:'rental'
    Template.latest_rentals.events
        'click .checkout_rental': ->
            new_id =
                Docs.insert 
                    model:'order'
                    order_type:'rental'
                    rental_id:@_id
                    parent_id:@_id
            Router.go "/order/#{new_id}/edit"
    Template.home.events
        'click .pick_user': ->
            console.log @
            Docs.insert 
                model:'checkin'
                active:true
                resident_user_id:@_id
                resident_username:@username
            Session.set('current_search_user',null)
            $('.search_user').val('')
        'keyup .search_user': _.throttle((e,t)->
            search_user = $('.search_user').val().trim().toLowerCase()
            # if search_user.length > 1
            #     Session.set('current_search_user', search_user)
            Session.set('current_search_user', search_user)
            console.log Session.get('current_search_user')
            # picked_tags.push search_user
            # # $( "p" ).blur();
        , 500)
    
        'click .checkin': ->
            if Meteor.userId() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        checkedin:true
                        checkedin_timestamp:Date.now()
                Docs.insert 
                    model:'checkin'
                    status:'active'
                    active:true
                    building_number:Meteor.user().building_number
                    unit_number:Meteor.user().unit_number
            else 
                Router.go '/login'
                
        'click .checkout': ->
            if Meteor.userId() 
                Meteor.users.update Meteor.userId(),
                    $set:
                        checkedin:false
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
                $('body').toast({
                    title: "#{resident.first_name} #{resident.last_name} checked out"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    showIcon:'checkmark'
                    showProgress:'bottom'
                    position:'top center'
                    className:
                        toast: 'ui massive green fluid icon message'
                    # displayTime: 5000
                    transition:
                      showMethod   : 'zoom',
                      showDuration : 250,
                      hideMethod   : 'fade',
                      hideDuration : 250
                    })
                            
            else 
                Router.go '/login'
                
    Template.guest_block.helpers
        guest_docs: ->
            Docs.find {
                model:'guest'
            }, 
                sort:_timestamp:-1
    Template.home.helpers
        checkedout_user_docs: ->
            match = {}
            if Session.get('current_search_user').length > 0
                match.username = {$regex:"#{Session.get('current_search_user')}", $options: 'i'}
            Meteor.users.find match
    
    Template.latest_activity.helpers
        activity_docs: ->
            Docs.find 
                model:'log'
            
    Template.latest_checkins.events 
        'click .delete_checkin': -> 
            if confirm 'delete checkin?'
                Docs.remove @_id
    Template.latest_checkins.helpers
        latest_checkin_docs: ->
            Docs.find {
                model:'checkin'
            }, 
                sort:
                    _timestamp:-1
    Template.latest_checkins.onCreated ->
        @autorun => Meteor.subscribe 'latest_model_docs','checkin', ->

if Meteor.isServer
    Meteor.publish 'checkedout_users_from_search', (username_search=null)->
        match = {}
        # match.checkedin = $ne:true
        if username_search and username_search.length > 0
            match.username = {$regex:"#{username_search}", $options: 'i'}
        Meteor.users.find match
            
    Meteor.publish 'latest_model_docs', (model)->
        Docs.find {
            model:model
        }, 
            sort:_timestamp:-1
            limit:10
            
    Meteor.publish 'active_checkins', ()->
        Docs.find {
            model:'checkin'
            active:true
        }
            
            
            