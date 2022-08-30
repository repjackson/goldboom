if Meteor.isClient 
    Router.route '/inbox', (->
        @layout 'layout'
        @render 'inbox'
        ), name:'inbox'


    Template.user_inbox.onCreated ->
        @autorun -> Meteor.subscribe 'unread_logs',->
    Template.user_inbox.events
        'click .mark_all_read': ->
            $('.ui.toast').toast('close')
            Meteor.call 'mark_unread_logs_read', ->

    Template.inbox.onCreated ->
        @autorun -> Meteor.subscribe 'my_messages',->
    Template.inbox.events 
        'click .new_message': ->
            new_id = 
                Docs.insert 
                    model:'message'
                    published:false 
                    sent:false
            Session.set('editing_id', new_id)
            
    Template.inbox.helpers 
        all_messages: ->
            Docs.find 
                model:'message'
        editing_doc: ->
            Docs.findOne Session.get('editing_id')
            
            
if Meteor.isServer 
    Meteor.publish 'my_messages', ->
        Docs.find 
            model:'message'
            _author_id:Meteor.userId()