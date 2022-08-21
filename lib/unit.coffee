Router.route '/units', -> @render 'units'
Router.route '/unit', -> @render 'units'
# Router.route '/unit/:doc_id', -> @render 'unit_view'
Router.route '/unit/:doc_id/edit', -> @render 'unit_edit'
# Router.route '/building/:building_number/unit/:unit_number', (->
Router.route '/unit/:doc_id', (->
    @layout 'layout'
    @render 'unit_view'
    ), name:'unit_view'


if Meteor.isClient
    Template.units.onCreated ->
        Session.setDefault('unit_number_filter',null)
        Session.setDefault('building_number_filter',null)
        @autorun => Meteor.subscribe 'units_pub',
            Session.get('unit_number_filter')
            Session.get('building_number_filter')
            ,->
    Template.unit_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => Meteor.subscribe 'unit_by_both', Router.current().params.building_number, Router.current().params.unit_number, ->
    Template.unit_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
    Template.unit_view.helpers
        current_unit: ->
            Docs.findOne 
                model:'unit'
            
    Template.unit_owners.onCreated ->
        @autorun => Meteor.subscribe 'unit_owners', Router.current().params.doc_id
    Template.unit_permits.onCreated ->
        @autorun => Meteor.subscribe 'unit_permits', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'unit_units', Router.current().params.unit_code


    Template.units.events
        'keyup .search_unit_number': ->
            val = $('.search_unit_number').val()
            Session.set('unit_number_filter',parseInt(val))
        'keyup .search_building_number': ->
            val = $('.search_building_number').val()
            Session.set('building_number_filter',parseint(val))
            
        'click .clear_filters': ->
            Session.set('unit_number_filter',null)
            Session.set('building_number_filter',null)
            val = $('.search_building_number').val(null)
            val = $('.search_unit_number').val(null)
        
        'click .add_unit': ->
            new_id = 
                Docs.insert 
                    model:'unit'
            Router.go "/unit/#{new_id}/edit"
            
            
    Template.units.helpers
        unit_docs: ->
            match = {model:'unit'}
            # if Session.get('unit_number_filter')
            #     match.unit_number = {$regex:"#{Session.get('unit_number_filter')}", $options: 'i'}
            # if Session.get('building_number_filter')
            #     match.building_number = {$regex:"#{Session.get('building_number_filter')}", $options: 'i'}

            Docs.find match,
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
         
if Meteor.isServer
    Meteor.methods 
        convert_units: ->
            cursor = Docs.find model:'unit'
            for unit in cursor.fetch()
                # unit_doc = Docs.findOne unit._id
                Docs.update unit._id,
                    $set:
                        unit_number_string:String(unit.unit_number)
                        building_number_string:String(unit.building_number)
    Meteor.publish 'units_pub', (
        unit_filter=null, 
        building_filter=null
        sort_key='_timestamp'
        sort_direction=-1
        )->
        match = {model:'unit'}

        # { $where: "/^123.*/.test(this.example)" })
        if unit_filter
            # "$expr": {
            #     "$regexMatch": {
            #       "input": {"$toString": "$name"}, 
            #       "regex": /123/ 
            #     }
            # }
            match.unit_number_string = {$regex:unit_filter, $options: 'i'}
        if building_filter
            match.building_number_string = {$regex:building_number, $options: 'i'}

        Docs.find match,
            sort:"#{sort_key}":sort_direction
                
                

if Meteor.isClient                
    Template.unit_owners.helpers
        owners: ->
            unit =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if unit
                Meteor.users.find
                    owner:true
                    # roles:$in:['owner']
                    building_number:unit.building_number
                    unit_number:unit.unit_number

    Template.unit_residents.onCreated ->
        @autorun => Meteor.subscribe 'unit_residents', Router.current().params.doc_id
    Template.unit_residents.helpers
        unit_resident_docs: ->
            unit =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if unit
                Meteor.users.find
                    # roles:$in:['resident','owner']
                    # owner:$ne:true
                    building_number:unit.building_number
                    unit_number:unit.unit_number

    Template.unit_permits.helpers
        permits: ->
            unit =
                Docs.findOne
                    _id: Router.current().params.doc_id
            if unit
                Docs.find
                    model: 'parking_permit'
                    address_number:unit.building_number

    Template.unit_view.helpers
        # unit: ->
        #     Docs.findOne
        #         model:'unit'
        #         slug: Router.current().params.unit_code

        units: ->
            Docs.find {
                model:'unit'
            }, sort: unit_number:1
                # unit_slug:Router.current().params.unit_code

    Template.unit_view.events
        'click .goto_building': ->
            found = 
                Docs.findOne 
                    model:'building'
                    building_number:@building_number
            if found 
                Router.go "/building/#{found._id}"
        # 'keyup .unit_number': (e,t)->
        #     if e.which is 13
        #         unit_number = parseInt($('.unit_number').val())
        #         unit_number = parseInt($('.unit_number').val())
        #         unit_label = $('.unit_label').val().trim()
        #         unit = Docs.findOne model:'unit'
        #         Docs.insert
        #             model:'unit'
        #             unit_number:unit_number
        #             unit_number:unit.unit_number
        #             unit_code:unit.slug



    Template.user_key.onCreated ->
        @autorun => Meteor.subscribe 'user_key', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'model_docs', 'unit_key_access'
    Template.user_key.helpers
        key: -> Docs.findOne model:'key'
        viewing_code: -> Session.get 'viewing_code'
        access_log: ->
            Docs.find {
                model:'unit_key_access'
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
                    model:'unit_key_access'
                    key_id:Docs.findOne(model:'key')._id
                    owner_user_id:Meteor.users.findOne username:Router.current().params.username
                    owner_username:Router.current().params.username
            else
                alert 'wrong code'



if Meteor.isServer
    Meteor.publish 'unit', (unit_code)->
        Docs.find
            model:'unit'
            slug:unit_code

    Meteor.publish 'unit_by_both', (building_number,unit_number)->
        Docs.find
            model:'unit'
            building_number:parseInt(building_number)
            unit_number:parseInt(unit_number)


    Meteor.publish 'unit_units', (unit_code)->
        Docs.find
            model:'unit'
            unit_code:unit_code


    Meteor.publish 'unit_owners', (unit_id)->
        unit =
            Docs.findOne
                _id:unit_id
        if unit
            Meteor.users.find
                # roles:$in:['owner']
                owner:true
                building_number:unit.building_number
                unit_number:unit.unit_number

    Meteor.publish 'unit_residents', (unit_id)->
        unit =
            Docs.findOne
                _id:unit_id
        if unit
            Meteor.users.find
                # roles:$in:['resident']
                building_number:unit.building_number
                unit_number:unit.unit_number

    Meteor.publish 'unit_permits', (unit_id)->
        unit =
            Docs.findOne
                _id:unit_id
        Docs.find
            model: 'parking_permit'
            address_number:unit.building_number