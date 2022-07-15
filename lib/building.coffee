Router.route '/buildings', -> @render 'buildings'
Router.route '/building/:building_number', -> @render 'building_view'
# Router.route '/building/:doc_id', -> @render 'building_view'
Router.route '/building/:doc_id/edit', -> @render 'building_edit'


if Meteor.isClient
    Template.buildings.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'building', ->
    Template.building_view.onCreated ->
        @autorun => Meteor.subscribe 'building', Router.current().params.building_number, ->
        @autorun => Meteor.subscribe 'building_units', Router.current().params.building_number, ->
        @autorun => Meteor.subscribe 'building_by_number', Router.current().params.building_number, ->
        # @autorun => Meteor.subscribe 'model_docs', 'building', ->
    Template.building_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'building_units', Router.current().params.building_number

    Template.buildings.onRendered ->

    Template.buildings.events
        'click .add_building': ->
            new_id = 
                Docs.insert 
                    model:'building'
            Router.go "/building/#{new_id}/edit"
            
            
    Template.buildings.helpers
        building_docs: ->
            Docs.find {
                model:'building'
            }, sort:slug:1

        building_unit_docs: ->
            current_building = 
                Docs.findOne
                    building_number:Router.current().params.building_number
                    model:'building'
            Docs.find 
                model:'unit'
                building_number:current_building.building_number
                

    Template.building_view.helpers
        current_building: ->
            console.log Router.current().params.building_number
            Docs.findOne
                model:'building'
                # building_number: Router.current().params.building_number

        units: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # building_slug:Router.current().params.building_number

    Template.buildings.events
        'mouseenter .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').addClass('raised')
        'mouseleave .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').removeClass('raised')


    Template.building_view.events
        'keyup .unit_number': (e,t)->
            if e.which is 13
                unit_number = parseInt $('.unit_number').val().trim()
                building_number = parseInt $('.building_number').val()
                building_label = $('.building_label').val().trim()
                building = Docs.findOne model:'building'
                Docs.insert
                    model:'unit'
                    unit_number:unit_number
                    building_number:building_number
                    building_number:building_number
                    building_number:building_label

        'keyup .building_search': (e,t)->
            username_search = $('.username_search').val()
            if e.which is 8
                if username_search.length is 0
                    Session.set 'username_search',null
                    Session.set 'checking_in',false
                else
                    Session.set 'username_search',username_search
            else
                if username_search.length > 1
                    # audio = new Audio('wargames.wav');
                    # audio.play();
                    Session.set 'username_search',username_search




if Meteor.isServer
    Meteor.publish 'building_by_number', (building_number)->
        console.log 'finding building', building_number
        Docs.find
            model:'building'
            building_number:parseInt(building_number)


    Meteor.publish 'building_units', (building_number)->
        Docs.find
            model:'unit'
            building_number:building_number