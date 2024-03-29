if Meteor.isClient
    Router.route '/users', -> @render 'users'
    Template.user_item.onCreated ->
        @autorun => Meteor.subscribe 'user_groups_small', @data.username, -> 
        
    Template.users.onCreated ->
        Session.setDefault('sort_key', 'createdAt')
        Session.set('view_friends', false)
        # @autorun -> Meteor.subscribe('users')
        Session.setDefault 'limit', 42
        @autorun => Meteor.subscribe 'user_counter', ->
        @autorun => Meteor.subscribe 'user_tags', 
            Session.get('user_search')
            picked_buildings.array()
            picked_units.array()
            , ->
        @autorun => Meteor.subscribe 'users_pub', 
            Session.get('user_search')
            picked_buildings.array()
            picked_units.array()
            # picked_user_tags.array()
            Session.get('sort_key')
            Session.get('sort_direction')
            Session.get('limit')
            ->
        # @autorun => Meteor.subscribe 'user_tags', picked_user_tags.array(), ->
     
if Meteor.isServer
    Meteor.publish 'user_tags', (
        # picked_tags
        username_search=''
        picked_buildings=[]
        picked_units=[]
        )->
        # user = Meteor.users.findOne @userId
        # current_herd = user.profile.current_herd
    
        self = @
        match = {}
    
        # picked_tags.push current_herd
        if picked_buildings.length > 0
            match.building_number = $all: picked_buildings
        if picked_units.length > 0
            match.unit_number = $all: picked_units
            
        count = Meteor.users.find(match).count()
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
        building_cloud = Meteor.users.aggregate [
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
        unit_cloud = Meteor.users.aggregate [
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
        
     
     
if Meteor.isClient     
    # Template.users.onCreated ->
    #     @autorun => Meteor.subscribe 'user_location_facets', picked_buildings.array(), picked_units.array(), ->
    Template.users.helpers
        building_results: -> Results.find model:'building_tag'
        picked_user_buildings: -> picked_buildings.array()
        unit_results: -> Results.find model:'unit_tag'
        picked_user_units: -> picked_units.array()
    Template.users.events
        'click .pick_building': -> picked_buildings.push @name
        'click .unpick_building': -> picked_buildings.remove @valueOf()
        'click .pick_unit': -> picked_units.push @name
        'click .unpick_unit': -> picked_units.remove @valueOf()
    
     
     
if Meteor.isServer 
    Meteor.publish 'users_pub', (
        username_search, 
        picked_buildings=[], 
        picked_units=[], 
        # picked_user_tags=[], 
        # view_friends=false
        sort_key='points'
        sort_direction=-1
        limit=50
    )->
        match = {}
        # if view_friends
        #     match._id = $in: Meteor.user().friend_ids
        if picked_buildings.length > 0 then match.building_number = $all:picked_buildings 
        if picked_units.length > 0 then match.unit_number = $all:picked_units
        if username_search
            match.username = {$regex:"#{username_search}", $options: 'i'}
        Meteor.users.find(match,{ 
            limit:42, 
            sort:
                "#{sort_key}":sort_direction
            fields:
                username:1
                # image_id:1
                building_number:1
                unit_number:1
                # tags:1
                # points:1
                # credit:1
                first_name:1
                last_name:1
                # group_memberships:1
                createdAt:1
                profile_views:1
        })
            
if Meteor.isClient
    Template.users.events
        'click .toggle_friends': -> Session.set('view_friends', !Session.get('view_friends'))
        'click .pick_user_tag': -> 
            picked_user_tags.push @name
            $('body').toast({
                title: "searching #{@name}"
                # message: 'Please see desk staff for key.'
                class : 'search'
                icon:'checkmark'
                position:'bottom right'
            })
                        
            
        'click .unpick_user_tag': -> 
            picked_user_tags.remove @valueOf()
                
        'keyup .search_user': (e,t)->
            username_query = $('.search_user').val()
            if e.which is 8
                if username_query.length is 0
                    Session.set 'username_query',null
                    # Session.set 'checking_in',false
                else
                    Session.set 'username_query',username_query
            else
                Session.set 'username_query',username_query

        'click .clear_query': ->
            Session.set('username_query',null)
    
        # 'click #add_user': ->
        #     id = Docs.insert model:'person'
        #     Router.go "/person/edit/#{id}"
        # 'keyup .username_search': (e,t)->
        #     username_search = $('.username_search').val()
        #     if e.which is 8
        #         if username_search.length is 0
        #             Session.set 'username_search',null
        #             Session.set 'checking_in',false
        #         else
        #             Session.set 'username_search',username_search
        #     else
        #         Session.set 'username_search',username_search
        'keyup .user_search': (e,t)->
            val = $('.user_search').val().trim().toLowerCase()
            Session.set('user_search',val)
            # if val.length > 2
            #     # if e.which is 13
            #     #     # picked_user_tags.clear()
            #     #     picked_user_tags.push val
            #     #     $('.user_search').val('')
            
            
            
    Template.add_user_button.events 
        'click .add_user': ->
            new_username = prompt('username')
            splitted = new_username.split(' ')
            formatted = new_username.split(' ').join('_').toLowerCase()
                #   return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
            Meteor.call 'add_user', formatted, (err,res)->
                new_user = Meteor.users.findOne res
                Meteor.users.update res,
                    $set:
                        first_name:splitted[0]
                        last_name:splitted[1]

                Router.go "/user/#{formatted}"
                $('body').toast({
                    title: "user created"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    icon:'user'
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

            
    Template.users.helpers
        building_results: -> Results.find({model:'building_tag'})
        unit_results: -> Results.find({model:'unit_tag'})
        user_count: ->  Counts.get('user_counter')
        # toggle_friends_class: -> if Session.get('view_friends',true) then 'blue large' else ''
        picked_user_tags: -> picked_user_tags.array()
        all_user_tags: -> Results.find model:'user_tag'
        
        location_tags: -> Results.find model:'location_tag'
        # all_user_tags: -> Results.find model:'user_tag'
        
        one_result: ->
            Meteor.users.find({_id:$ne:Meteor.userId()}).count() is 1
        username_query: -> Session.get('username_query')
        user_docs: ->
            match = {}
            username_query = Session.get('username_query')
            if username_query
                match.username = {$regex:"#{username_query}", $options: 'i'}
            if picked_user_tags.array().length > 0
                match.tags = $all: picked_user_tags.array()
                
            match._id = $ne:Meteor.userId()
            Meteor.users.find(match
                # roles:$in:['resident','owner']
            ,
                # limit:Session.get('limit')
                # limit:42
                sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
            )
        current_user_search: -> Session.get('current_user_search')
        # users: ->
        #     username_search = Session.get('username_search')
        #     Meteor.users.find({
        #         username: {$regex:"#{username_search}", $options: 'i'}
        #         # healthclub_checkedin:$ne:true
        #         # roles:$in:['resident','owner']
        #         },{ 
        #             limit:100
        #             sort:"#{Session.get('sort_key')}":Session.get('sort_direction')
        #     })


        
        
if Meteor.isServer 
    Meteor.methods
        calc_user_tags: (user_id)->
            debit_tags = Meteor.call 'omega', user_id, 'debit'
            # debit_tags = Meteor.call 'omega', user_id, 'debit', (err, res)->
            Meteor.users.update user_id, 
                $set:
                    debit_tags:debit_tags
    
            credit_tags = Meteor.call 'omega', user_id, 'credit'
            Meteor.users.update user_id, 
                $set:
                    credit_tags:credit_tags
    
    
        omega: (user_id, direction)->
            user = Meteor.users.findOne user_id
            options = {
                explain:false
                allowDiskUse:true
            }
            match = {}
            match.model = 'debit'
            if direction is 'debit'
                match._author_id = user_id
            if direction is 'credit'
                match.target_id = user_id
    
            # if omega.selected_tags.length > 0
            #     limit = 42
            # else
            # limit = 10
            # { $match: tags:$all: omega.selected_tags }
            pipe =  [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                # { $match: _id: $nin: omega.selected_tags }
                { $sort: count: -1, _id: 1 }
                { $limit: 42 }
                { $project: _id: 0, title: '$_id', count: 1 }
            ]
    
            if pipe
                agg = global['Docs'].rawCollection().aggregate(pipe,options)
                # else
                res = {}
                if agg
                    agg.toArray()
                    # omega = Docs.findOne model:'omega_session'
                    # Docs.update omega._id,
                    #     $set:
                    #         agg:agg.toArray()
            else
                return null
            
            
            


if Meteor.isServer
    # Meteor.publish 'user_search', (username, role)->
    #     if role
    #         Meteor.users.find({
    #             username: {$regex:"#{username}", $options: 'i'}
    #             roles:$in:[role]
    #         },{ limit:150})
    #     else
    #         Meteor.users.find({
    #             username: {$regex:"#{username}", $options: 'i'}
    #         },{ limit:150})
            
            
    Meteor.publish 'user_counter', ()->
        Counts.publish this, 'user_counter', 
            Docs.find({
                model:'user'
            })
        return undefined
        
        
        