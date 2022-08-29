Router.route '/keys', -> @render 'keys'
Router.route '/key', -> @render 'keys'
Router.route '/key/:doc_id', -> @render 'key_view'
Router.route '/key/:doc_id/edit', -> @render 'key_edit'


if Meteor.isClient
    Template.keys.onCreated ->
        document.title = 'gr keys'
        Session.setDefault('sort_key','_timestamp')
        Session.setDefault('sort_direction',-1)
        Session.setDefault('building_number', null)
        Session.setDefault('unit_number', null)
        @autorun => Meteor.subscribe 'key_tags', 
            Session.get('building_number')
            Session.get('unit_number')
            picked_buildings.array()
            picked_units.array()
            , ->
        @autorun => Meteor.subscribe 'keys_pub', 
            Session.get('building_number')
            Session.get('unit_number')
            picked_buildings.array()
            picked_units.array()
            # picked_user_tags.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
            ->
    Template.key_view.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
        document.title = 'gr view key'
    Template.key_edit.onCreated ->
        document.title = 'gr edit key'
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id, ->
            
    Template.keys.events
        'click .add_key': ->
            new_id = 
                Docs.insert 
                    model:'key'
            Router.go "/key/#{new_id}/edit"
    Template.keys.helpers
        key_docs: ->
            Docs.find {
                model:'key'
            },
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')

    Template.keys.helpers
        building_results: -> Results.find model:'building_tag'
        picked_buildings: -> picked_buildings.array()
        unit_results: -> Results.find model:'unit_tag'
        picked_units: -> picked_units.array()
    Template.keys.events
        'click .pick_building': -> picked_buildings.push @name
        'click .unpick_building': -> picked_buildings.remove @valueOf()
        'click .pick_unit': -> picked_units.push @name
        'click .unpick_unit': -> picked_units.remove @valueOf()



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
                
                
    Meteor.publish 'key_tags', (
        # picked_tags
        building_number
        unit_number
        picked_buildings=[]
        picked_units=[]
        )->
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {model:'key'}
    
        # picked_tags.push current_herd
        if picked_buildings.length > 0
            match.building_number = $all: picked_buildings
        if picked_units.length > 0
            match.unit_number = $all: picked_units
            
        count = Docs.find(match).count()
        # cloud = Meteor.users.aggregate [
        #     { $match: match }
        #     { $project: tags: 1 }
        #     { $unwind: "$tags" }
        #     { $group: _id: '$tags', count: $sum: 1 }
        #     { $match: _id: $nin: picked_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $match: count: $lt: count }
        #     { $limit: 20 }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # cloud.forEach (tag, i) ->
    
        #     self.added 'results', Random.id(),
        #         name: tag.name
        #         count: tag.count
        #         model:'user_tag'
        #         index: i
        building_cloud = Docs.aggregate [
            { $match: match }
            { $project: building_number: 1 }
            # { $unwind: "$location_tags" }
            { $group: _id: '$building_number', count: $sum: 1 }
            { $match: _id: $nin: picked_buildings }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        building_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'building_tag'
                index: i
        unit_cloud = Docs.aggregate [
            { $match: match }
            { $project: unit_number: 1 }
            # { $unwind: "$location_tags" }
            { $group: _id: '$unit_number', count: $sum: 1 }
            { $match: _id: $nin: picked_units }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: count }
            { $limit: 20 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        unit_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'unit_tag'
                index: i

        self.ready()
        
     
    Meteor.publish 'keys_pub', (
        building_number, 
        unit_number, 
        picked_buildings=[], 
        picked_units=[], 
        # picked_user_tags=[], 
        # view_friends=false
        sort_key='points'
        sort_direction=-1
        limit=50
    )->
        match = {model:'key'}
        # if view_friends
        #     match._id = $in: Meteor.user().friend_ids
        if picked_buildings.length > 0 then match.building_number = $all:picked_buildings 
        if picked_units.length > 0 then match.unit_number = $all:picked_units
        # if username_search
        #     match.username = {$regex:"#{username_search}", $options: 'i'}
        Docs.find(match,{ 
            limit:limit, 
            sort:
                "#{sort_key}":sort_direction
            # fields:
            #     username:1
            #     # image_id:1
            #     building_number:1
            #     unit_number:1
            #     # tags:1
            #     # points:1
            #     # credit:1
            #     first_name:1
            #     last_name:1
            #     # group_memberships:1
            #     createdAt:1
            #     profile_views:1
        })
                