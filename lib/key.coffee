Router.route '/keys', -> @render 'keys'
Router.route '/key', -> @render 'keys'
Router.route '/key/:doc_id', -> @render 'key_view'
Router.route '/key/:doc_id/edit', -> @render 'key_edit'


if Meteor.isClient
    Template.keys.onCreated ->
        document.title = 'gr keys'
        @autorun => Meteor.subscribe 'model_docs', 'key', ->
    Template.key_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        document.title = 'gr view key'
    Template.key_edit.onCreated ->
        document.title = 'gr edit key'
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
    Template.keys.helpers
        key_docs: ->
            Docs.find {
                model:'key'
            },
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
                
    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'key_access'
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
                    model:'key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
            else
                alert 'wrong code'










if Meteor.isServer
    Meteor.publish 'key', (key_code)->
        Docs.find
            model:'key'
            slug:key_code


    Meteor.publish 'user_key', (key_id)->
        key = Docs.findOne key_id
        if key
            Docs.find
                model:'key'
                building_number:key.building_number
                key_number:key.key_number