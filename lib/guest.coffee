Router.route '/guests', -> @render 'guests'
# Router.route '/guest/:guest_number', -> @render 'guest_view'
Router.route '/guest/:doc_id', -> @render 'guest_view'
Router.route '/guest/:doc_id/edit', -> @render 'guest_edit'


if Meteor.isClient
    Template.guests.onCreated ->
        @autorun => Meteor.subscribe 'model_docs', 'guest', ->
    Template.guest_view.onCreated ->
        # @autorun => Meteor.subscribe 'guest', Router.current().params.guest_number, ->
        # @autorun => Meteor.subscribe 'guest_units', Router.current().params.guest_number, ->
        # @autorun => Meteor.subscribe 'guest_by_number', Router.current().params.guest_number, ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'unit', ->
    Template.guest_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'guest_units', Router.current().params.guest_number

    Template.guests.onRendered ->

    Template.guests.events
        'click .add_guest': ->
            new_id = 
                Docs.insert 
                    model:'guest'
            Router.go "/guest/#{new_id}/edit"
            
    Template.guests.helpers
        guest_docs: ->
            Docs.find {
                model:'guest'
            },
                sort:"#{Session.get('sort_key')}":parseInt(Session.get('sort_direction'))

        guest_unit_docs: ->
            current_guest = 
                Docs.findOne
                    guest_number:Router.current().params.guest_number
                    model:'guest'
            Docs.find 
                model:'unit'
                guest_number:current_guest.guest_number
                

    Template.guest_view.helpers
        current_guest: ->
            Docs.findOne
                model:'guest'
                # guest_number: Router.current().params.guest_number

        guest_unit_docs: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # guest_slug:Router.current().params.guest_number

    Template.guests.events
        'mouseenter .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').addClass('raised')
        'mouseleave .home_segment': (e,t)->
            t.$(e.currentTarget).closest('.home_segment').removeClass('raised')


    Template.guest_view.events
        'keyup .unit_number': (e,t)->
            if e.which is 13
                unit_number = parseInt $('.unit_number').val().trim()
                guest_number = parseInt $('.guest_number').val()
                guest_label = $('.guest_label').val().trim()
                guest = Docs.findOne model:'guest'
                Docs.insert
                    model:'unit'
                    unit_number:unit_number
                    guest_number:guest_number
                    guest_number:guest_number
                    guest_number:guest_label

        'keyup .guest_search': (e,t)->
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
    Meteor.publish 'guest_by_number', (guest_number)->
        Docs.find
            model:'guest'
            guest_number:parseInt(guest_number)

    Meteor.publish 'guest_residents', (guest_number)->
        Meteor.users.find
            guest_number:parseInt(guest_number)


    Meteor.publish 'guest_units', (guest_number)->
        Docs.find
            model:'unit'
            guest_number:guest_number