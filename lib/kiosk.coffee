if Meteor.isClient
    Router.route '/kiosk', (->
        @layout 'mlayout'
        @render 'kiosk_container'
        ), name:'kiosk_container'
    
    
    Template.kiosk_container.onCreated ->
        @autorun -> Meteor.subscribe 'model_docs','building', ->
        # @autorun -> Meteor.subscribe 'kiosk_buildings', ->
            
        # @autorun -> Meteor.subscribe 'all_users', ->
        @autorun -> Meteor.subscribe 'kiosk_document', ->
    Template.unit_picker.onCreated ->
        @autorun -> Meteor.subscribe 'kiosk_units', ->
if Meteor.isServer 
    Meteor.publish 'kiosk_units', ->
        if Meteor.isDevelopment
            kiosk = 
                Docs.findOne 
                    model:'kiosk'
                    dev:true
        else 
            kiosk = 
                Docs.findOne 
                    model:'kiosk'
        # if kiosk.current_building_number
        Docs.find
            model:'unit'
            building_number:kiosk.current_building_number
if Meteor.isClient
    # Template.kiosk_settings.onCreated ->
    #     @autorun -> Meteor.subscribe 'kiosk_document', ->

    Template.resident_picker.onCreated ->
        # @autorun => Meteor.subscribe 'checkedout_users_from_search', Session.get('current_search_user'), ->
        @autorun => Meteor.subscribe 'kiosk_residents', ->
if Meteor.isServer 
    Meteor.publish 'kiosk_residents', ->
        if Meteor.isDevelopment
            kiosk = 
                Docs.findOne 
                    model:'kiosk'
                    dev:true
        else 
            kiosk = 
                Docs.findOne 
                    model:'kiosk'
        # if kiosk.current_building_number
        Meteor.users.find
            building_number:kiosk.current_building_number
            unit_number:kiosk.current_unit_number
if Meteor.isClient
    Template.kiosk_settings.onRendered ->
        # Meteor.setTimeout ->
        #     $('.button').popup()
        # , 3000

    Template.set_kiosk_template.events
        'click .set_kiosk_template': ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            Docs.update kiosk_doc._id,
                $set:kiosk_view:@value

    Template.kiosk_settings.events
        'click .create_kiosk': (e,t)->
            Docs.insert
                model:'kiosk'

        'click .print_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            console.log kiosk

        'click .delete_kiosk': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk
                if confirm "delete  #{kiosk._id}?"
                    Docs.remove kiosk._id
    Template.kiosk_settings.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view

    Template.kiosk_container.events 
        'click .make': ->
            if Meteor.isDevelopment
                Docs.insert 
                    model:'kiosk'
                    dev:true
            else 
                Docs.insert 
                    model:'kiosk'
        'click .set_home': ->
            found = Docs.findOne
                model:'kiosk'
            Docs.update found._id, 
                $set:kiosk_view:'settings'
    Template.healthclub.events 
        'click .pick_building': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk.current_building_number is @building_number
                Docs.update(kiosk._id, 
                    $unset:
                        current_building_number:1
                        current_unit_number:1
                    )
                # Session.set('current_building_number', null)
                # Session.set('current_unit_number',null)
                $(e.currentTarget).closest('.label').transition('shake', 500)
            else 
                # Session.set('current_building_number', @building_number)
                # Session.set('current_unit_number',null)
                Docs.update(kiosk._id, 
                    $set:
                        current_building_number:@building_number
                    $unset:
                        current_unit_number:1
                    )
                $(e.currentTarget).closest('.label').transition('jiggle', 500)
        'click .pick_unit': (e,t)->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk.current_unit_number is @unit_number
                # Session.set('current_unit_number', null)
                Docs.update(kiosk._id, 
                    $set:
                        current_unit_number:null
                )
                $(e.currentTarget).closest('.label').transition('shake', 500)
            else 
                # Session.set('current_unit_number', @unit_number)
                Docs.update(kiosk._id, 
                    $set:
                        current_unit_number:@unit_number
                    )
                $(e.currentTarget).closest('.label').transition('jiggle', 500)
    Template.resident_picker.events
        'keyup .new_resident_name':(e)->
            if e.which in [13,9]
                kiosk = Docs.findOne model:'kiosk'
                # new_username = prompt('first and last name')
                new_username = $('.new_resident_name').val()
                splitted = new_username.split(' ')
                formatted = new_username.split(' ').join('_').toLowerCase()
                console.log formatted
                Meteor.call 'add_user', formatted, (err,res)->
                    if err 
                        alert err.reason
                    else 
                        console.log res
                        # new_user = Meteor.users.findOne res
                        
                        Meteor.users.update res,
                            $set:
                                building_number:parseInt(kiosk.current_building_number)
                                unit_number:parseInt(kiosk.current_unit_number)
                                first_name:splitted[0]
                                last_name:splitted[1]
                                roles:['resident']
                                verified:false
                        # Router.go "/user/#{formatted}"
                        new_id = 
                            Docs.insert 
                                model:'checkin'
                                active:true
                                resident_user_id:res
                                resident_username:formatted
                                building_number:kiosk.current_building_number
                                unit_number:kiosk.current_unit_number
                        
                        Meteor.users.update res._id,
                            $set:
                                checked_in:true
                        Docs.update kiosk._id, 
                            $set:
                                current_search_user:null
                                current_building_number:null
                                current_unit_number:null
                        $(e.currentTarget).closest('.grid').transition('fly right', 500)
   
                        Router.go "/checkin/#{new_id}/edit"
                        
                        $('body').toast({
                            title: "#{splitted[0]} added"
                            # message: 'Please see desk staff for key.'
                            class : 'success'
                            icon:'user plus'
                            position:'bottom right'
                            # className:
                            #     toast: 'ui massive message'
                            # displayTime: 5000
                            transition:
                              showMethod   : 'zoom',
                              showDuration : 250,
                              hideMethod   : 'fade',
                              hideDuration : 250
                            })
                

        'click .pick_user': (e)->
            console.log @
            kiosk = Docs.findOne model:'kiosk'
            
            new_id = 
                Docs.insert 
                    model:'checkin'
                    active:true
                    resident_user_id:@_id
                    resident_username:@username
                    building_number:kiosk.current_building_number
                    unit_number:kiosk.current_unit_number
            
            Meteor.users.update @_id,
                $set:
                    checked_in:true
            Docs.update kiosk._id, 
                $set:
                    current_search_user:null
                    current_building_number:null
                    current_unit_number:null
            $(e.currentTarget).closest('.grid').transition('fly right', 500)

            Router.go "/checkin/#{new_id}/edit"
            # Session.set('current_search_user',null)
            
            # Session.set('current_building_number',null)
            # Session.set('current_unit_number',null)
            $('.search_user').val('')
            # $('body').toast({
            #     title: "#{@first_name} #{@last_name} checked in"
            #     # message: 'Please see desk staff for key.'
            #     class : 'success'
            #     showIcon:'checkmark'
            #     showProgress:'bottom'
            #     position:'top center'
            #     className:
            #         toast: 'ui massive green fluid message'
            #     # displayTime: 5000
            #     transition:
            #       showMethod   : 'zoom',
            #       showDuration : 250,
            #       hideMethod   : 'fade',
            #       hideDuration : 250
            #     })
            
        # 'keyup .search_user': _.throttle((e,t)->
        #     kiosk = Docs.findOne model:'kiosk'
        #     search_user = $('.search_user').val().trim().toLowerCase()
        #     # if search_user.length > 1
        #     #     Session.set('current_search_user', search_user)
        #     Docs.update kiosk._id, 
        #         $set:
        #             current_search_user:search_user
        #     # Session.set('current_search_user', search_user)
        #     # console.log Session.get('current_search_user')
        #     # picked_tags.push search_user
        #     # # $( "p" ).blur();
        # , 500)
        # 'keyup .add_unit_number': _.throttle((e,t)->
        #     kiosk = Docs.findOne model:'kiosk'
        #     new_unit_number = parseInt($('.add_unit_number').val())
        #     # if search_user.length > 1
        #     #     Session.set('current_search_user', search_user)
        #     if e.which is 13
        #         Docs.insert 
        #             model:'unit'
        #             building_number:parseInt(kiosk.current_building_number)
        #             unit_number:new_unit_number
        #         Docs.update kiosk._id,
        #             $set:
        #                 current_unit_number:new_unit_number
        #         # Session.set('current_unit_number', new_unit_number)
        # , 500)
        # 'click .add_new_unit': (e)->
        #     kiosk = Docs.findOne model:'kiosk'
        #     Docs.update kiosk._id,
        #         $set:
        #             adding_unit:true
        #     $('.add_unit_number').focus()
        #     # val = Swal.fire({
        #     #     title: 'Input email address',
        #     #     input: 'number',
        #     #     inputLabel: 'Your email address',
        #     #     inputPlaceholder: 'Enter your email address'
        #     # })
        #     # if val
        #     #     Swal.fire("Entered email: #{val}")
        #     # `const { value: email } = await Swal.fire({
        #     #   title: 'Input email address',
        #     #   input: 'email',
        #     #   inputLabel: 'Your email address',
        #     #   inputPlaceholder: 'Enter your email address'
        #     # })`
        #     # if email
        #     #     Swal.fire("Entered email: #{email}")
    Template.unit_picker.events
        'keyup .add_unit_number': (e)->
            kiosk = Docs.findOne model:'kiosk'
            val = parseInt($('.add_unit_number').val())
            console.log val
            if kiosk.current_building_number is 1
                if val.toString().length is 4
                    Docs.insert 
                        model:'unit'
                        building_number:parseInt(kiosk.current_building_number)
                        unit_number:val
                    Docs.update kiosk._id,
                        $set:
                            current_unit_number:val
            else 
                if val.toString().length is 3
                    Docs.insert 
                        model:'unit'
                        building_number:parseInt(kiosk.current_building_number)
                        unit_number:val
                    Docs.update kiosk._id,
                        $set:
                            current_unit_number:val


    Template.kiosk_container.helpers
        kiosk_doc: ->
            Docs.findOne
                model:'kiosk'
        kiosk_view: ->
            kiosk_doc = Docs.findOne
                model:'kiosk'
            kiosk_doc.kiosk_view
    Template.unit_picker.helpers
        kiosk_doc: -> 
            Docs.findOne model:'kiosk'
    Template.healthclub.helpers
        kiosk_doc: -> 
            Docs.findOne model:'kiosk'
        # selected_building: -> Session.get('current_building_number')
        # selected_unit: -> Session.get('current_unit_number')
        building_button_class: -> 
            kiosk = Docs.findOne model:'kiosk'
            if kiosk.current_building_number is @building_number then 'black massive' else 'big black basic'
        building_docs: ->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk.current_building_number
                Docs.find 
                    model:'building'
                    building_number:kiosk.current_building_number
            else 
                Docs.find {
                    model:'building'
                }, 
                    sort:building_number:1
    Template.unit_picker.helpers
        unit_button_class: -> 
            kiosk = Docs.findOne model:'kiosk'
            if kiosk.current_unit_number is @unit_number then 'black circular massive' else 'big basic circular black'
        unit_docs: ->
            kiosk = Docs.findOne model:'kiosk'
            if kiosk.current_unit_number
                Docs.find {
                    model:'unit'
                    building_number:kiosk.current_building_number
                    unit_number:kiosk.current_unit_number
                }, sort:unit_number:1
            else 
                Docs.find {
                    model:'unit'
                    building_number:kiosk.current_building_number
                }, sort:unit_number:1
    Template.resident_picker.helpers
        checkedout_user_docs: ->
            kiosk = Docs.findOne model:'kiosk'
            match = {}
            # match.checked_in = $ne:true
            match.building_number = kiosk.current_building_number
            match.unit_number = kiosk.current_unit_number
            # if Session.get('current_search_user').length > 1
            #     match.username = {$regex:"#{Session.get('current_search_user')}", $options: 'i'}
            Meteor.users.find match


    Template.healthclub_session.onCreated ->
        # @autorun => Meteor.subscribe 'current_poll'
        @autorun => Meteor.subscribe 'doc', Session.get('new_guest_id')
        @autorun => Meteor.subscribe 'checkin_guests',Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'resident_from_healthclub_session', Router.current().params.doc_id
        @autorun -> Meteor.subscribe 'healthclub_session', Router.current().params.doc_id
        # @autorun -> Meteor.subscribe 'model_docs', 'guest'

        # @autorun => Meteor.subscribe 'rules_signed_username', @data.username
    Template.healthclub_session.onRendered ->
        # @timer = new ReactiveVar 5
        # Session.set 'timer',5
        # Session.set 'timer_engaged', false
        # Meteor.setTimeout ->
        #     healthclub_session_document = Docs.findOne Router.current().params.doc_id
        #     # console.log @
        #     if healthclub_session_document and healthclub_session_document.user_id
        #         resident = Meteor.users.findOne healthclub_session_document.user_id
        #         # if resident.user_id
        #         rules_found = Docs.findOne
        #             model:'rules_and_regs_signing'
        #             resident:resident.username
        #         if resident.rules_and_regulations_signed and resident.member_waiver_signed
        #             Session.set 'timer_engaged', true
        #             interval_id = Meteor.setInterval( ->
        #                 if Session.equals 'timer_engaged', true
        #                     if Session.equals 'timer', 0
        #                         Meteor.call 'submit_checkin'
        #                         Meteor.clearInterval interval_id
        #                     else
        #                         Session.set('timer', Session.get('timer')-1)
        #                 # t.timer.set(t.timer.get()-1)
        #             ,1000)
        # , 4000
        # Session.set 'loading_checkin', false
        # alert 'stop loading'



    Template.healthclub_session.events
        'click .vote_yes': ->
            $('.poll_area').transition('fade out', 500)
            Meteor.setTimeout =>
                healthclub_session_document = Docs.findOne Router.current().params.doc_id
                Meteor.call 'kiosk_vote_yes', @_id, healthclub_session_document.user_id
            , 500
            $('.poll_area').transition('fade in', 500)

        'click .vote_no': ->
            $('.poll_area').transition('fade out', 500)
            Meteor.setTimeout =>
                healthclub_session_document = Docs.findOne Router.current().params.doc_id
                Meteor.call 'kiosk_vote_no', @_id, healthclub_session_document.user_id
            , 500
            $('.poll_area').transition('fade in', 500)


        'click .cancel_checkin': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            if healthclub_session_document
                Docs.remove healthclub_session_document._id
            if healthclub_session_document and healthclub_session_document.user_id
                Meteor.users.update healthclub_session_document.user_id,
                    $inc:
                        checkins_without_email_verification:-1
                        checkins_without_gov_id:-1

            Router.go "/healthclub"

        # 'click .recheck_photo': ->
        #     healthclub_session_document = Docs.findOne Router.current().params.doc_id
        #     if healthclub_session_document and healthclub_session_document.user_id
        #         user = Meteor.users.findOne healthclub_session_document.user_id
        #         Meteor.call 'image_check', user
        #         Meteor.call 'staff_government_id_check', user
        #
        #
        #
        # 'click .recheck': ->
        #     console.log @
        #     Meteor.call 'run_user_checks', @
        #     Meteor.call 'member_waiver_signed', @
        #     Meteor.call 'rules_and_regulations_signed', @

        'click .add_guest': ->
            # console.log @
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_guest_id =
                Docs.insert
                    model:'guest'
                    session_id: healthclub_session_document._id
                    resident_id: healthclub_session_document.user_id
                    resident: healthclub_session_document.resident_username
            # Session.set 'displaying_profile', null
            #
            Router.go "/add_guest/#{new_guest_id}"

        'click .sign_rules': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'rules_and_regs_signing'
                session_id: healthclub_session_document._id
                resident_id: healthclub_session_document.user_id
                resident: healthclub_session_document.resident_username
            Router.go "/sign_rules/#{new_id}/#{healthclub_session_document.resident_username}"
            # Session.set 'displaying_profile',null


        'click .sign_guidelines': ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            new_id = Docs.insert
                model:'member_guidelines_signing'
                session_id: healthclub_session_document._id
                resident_id: healthclub_session_document.user_id
                resident: healthclub_session_document.resident_username
            Router.go "/sign_guidelines/#{new_id}/#{healthclub_session_document.resident_username}"
            # Session.set 'displaying_profile',null

        'click .add_recent_guest': ->
            current_session = Docs.findOne
                model:'healthclub_session'
                current:true
            Docs.update current_session._id,
                $addToSet:guest_ids:@_id

        'click .remove_guest': ->
            current_session = Docs.findOne
                model:'healthclub_session'
                current:true
            # console.log current_session
            Docs.update current_session._id,
                $pull:guest_ids:@_id

        'click .toggle_adding_guest': ->
            Session.set 'adding_guest', true
            Session.set 'timer_engaged', false

        'click .submit_checkin': (e,t)->
            Meteor.call 'submit_checkin'

        'click .cancel_auto_checkin': (e,t)->
            Session.set 'timer_engaged',false

    Template.healthclub_session.helpers
        current_poll: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            # healthclub_session_document.user_id

            Docs.findOne
                model:'vote'
                upvoter_ids: $nin:[healthclub_session_document.user_id]
                downvoter_ids: $nin:[healthclub_session_document.user_id]

        timer_engaged: ->
            Session.get 'timer_engaged'
        timer: ->
            Session.get 'timer'
            # console.log Template.instance()
            # Template.instance().timer.get()

        rules_signed: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            if healthclub_session_document.user_id
                resident = Meteor.users.findOne healthclub_session_document.user_id
                # if resident.user_id
                Docs.findOne
                    model:'rules_and_regs_signing'
                    resident:resident.username
        session_document: -> Docs.findOne Router.current().params.doc_id

        adding_guests: -> Session.get 'adding_guest'
        checking_in_doc: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log healthclub_session_document
            healthclub_session_document
        checkin_guest_docs: () ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            # console.log @
            Docs.find
                _id:$in:healthclub_session_document.guest_ids

        user: ->
            healthclub_session_document = Docs.findOne Router.current().params.doc_id
            if healthclub_session_document and healthclub_session_document.user_id
                Meteor.users.findOne healthclub_session_document.user_id


    Template.resident_guest.onCreated ->
        # console.log @
        @autorun => Meteor.subscribe 'doc', @data
    Template.resident_guest.helpers
        guest_doc: ->
            Docs.findOne Template.currentData()


    Template.healthclub_stats.events
        'click .recalc': ->
            console.log @
            Meteor.call 'recalc_healthclub_stats', @user



if Meteor.isServer
    Meteor.publish 'kiosk_document', ()->
        if Meteor.isDevelopment
            Docs.find
                model:'kiosk'
                dev:true
        else         
            Docs.find
                model:'kiosk'
            

    Meteor.methods
        convert_units: ->
            # units = Docs.find(model:'unit')
            # # for unit in units.fetch()
            # #     console.log typeof(unit.unit_number)
            # #     Docs.update unit._id,
            # #         $set:
            # #             unit_number:parseInt(unit.unit_number)
            # checkins = Docs.find(model:'checkin')
            # for checkin in checkins.fetch()
            #     console.log typeof(checkin.unit_number)
            #     Docs.update checkin._id,
            #         $set:
            #             unit_number:parseInt(checkin.unit_number)
            # users = Meteor.users.find()
            # for user in users.fetch()
            #     console.log typeof(user.unit_number)
            #     Meteor.users.update user._id,
            #         $set:
            #             unit_number:parseInt(user.unit_number)
            #     console.log 'after',typeof(user.unit_number)
                
        kiosk_vote_no: (poll_id, user_id)->
            console.log poll_id, user_id
            Docs.update poll_id,
                $addToSet: downvoter_ids: user_id
        kiosk_vote_yes: (poll_id, user_id)->
            console.log poll_id, user_id
            Docs.update poll_id,
                $addToSet: upvoter_ids: user_id


        recalc_healthclub_stats: (user)->
            # console.log user
            session_count =
                Docs.find(
                    model:'healthclub_session'
                    user_id:user._id
                ).count()
            # console.log session_count
            Meteor.users.update user._id,
                $set:total_session_count:session_count
            sorted_session_count =
                Meteor.users.find({
                    total_session_count:$exists:1
                },
                    sort:total_session_count:-1
                    fields:
                        username:1
                        total_session_count:1
                ).fetch()
            # console.log total_top_ten
            found_in_ranking = _.findWhere(sorted_session_count,{username:user.username})
            console.log 'found', found_in_ranking
            global_rank = _.indexOf(sorted_session_count,found_in_ranking)+1
            if global_rank > 0
                Meteor.users.update user._id,
                    $set:global_rank:global_rank

    # publishComposite 'healthclub_session', (doc_id)->
    #     {
    #         find: ->
    #             Docs.find doc_id
    #         children: [
    #             { find: (doc) ->
    #                 Meteor.users.find
    #                     _id: doc.user_id
    #                 }
    #             { find: (doc) ->
    #                 Docs.find
    #                     model: 'guest'
    #                     _id:doc.guest_ids
    #                 }
    #             ]
    #     }