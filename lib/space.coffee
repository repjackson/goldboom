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
                
                
                
    Template.doc_residents.onCreated ->
        @autorun => Meteor.subscribe 'doc_residents', Router.current().params.doc_id
    Template.doc_residents.helpers
        doc_resident_docs: ->
            space =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if space
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:space.building_number
                    space_number:space.space_number


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