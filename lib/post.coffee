if Meteor.isClient
    Template.posts.onCreated ->
        document.title = 'gr posts'
        
        Session.setDefault('view_mode', 'list')
        Session.setDefault('current_search', null)
        Session.setDefault('dummy', false)
        Session.setDefault('is_loading', false)
        @autorun => @subscribe 'doc_by_id', Session.get('full_doc_id'), ->
        # @autorun => @subscribe 'agg_emotions',
        #     picked_tags.array()
        #     Session.get('dummy')
        @autorun => Meteor.subscribe 'model_counter','post', ->
        @autorun => Meteor.subscribe 'kiosk_posts', ->
        # @autorun => @subscribe 'model_docs', 'post', ->
        # @autorun => @subscribe 'post_tag_results',
        #     picked_tags.array()
            
        # @autorun => @subscribe 'doc_results',
        #     picked_tags.array()
        #     # Session.get('dummy')
    
    
    
    Router.route '/post/:doc_id', (->
        @layout 'layout'
        @render 'post_view'
        ), name:'post_view'
    Router.route '/post/:doc_id/edit', (->
        @layout 'layout'
        @render 'post_edit'
        ), name:'post_edit'
        
    Router.route '/posts', (->
        @layout 'layout'
        @render 'posts'
        ), name:'posts'
        
if Meteor.isServer
    Meteor.publish 'kiosk_posts', ->
        match = {model:'post'}
        unless Meteor.userId()
            match.public = true
        Docs.find match,
            sort:_timestamp:-1            
        
if Meteor.isClient
    Template.posts.helpers
        total_post_count: -> Counts.get('model_counter') 
        doc_results: ->
            Docs.find 
                model:'post'

    Template.post_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.post_edit.events
        'click .cancel_note': (e)->
            $(e.currentTarget).closest('.grid').transition('fly right', 1000)
            kiosk = Docs.findOne model:'kiosk'
            
            Docs.update kiosk._id, 
                $set:
                    current_route:'checkin_edit'
                    current_doc_id:null
            # Docs.update @_id,
            #     submitted:true
            # Router.go "/checkin/#{@checkin_id}/edit"

            Docs.remove @_id
            # Swal.fire({
            #     title: "thanks for your feedback"
            #     # title: "checked in"
            #     # text: "point bounty will be held "
            #     icon: 'success'
            #     timer:2000
            #     # background: 'green'
            #     timerProgressBar:true
            #     showClass: {popup: 'animate__animated animate__fadeInDown'}
            #     hideClass: {popup: 'animate__animated animate__fadeOutUp'}
            #     showConfirmButton:false
            #     # confirmButtonText: 'publish'
            #     # confirmButtonColor: 'green'
            #     # showCancelButton: true
            #     # cancelButtonText: 'cancel'
            #     # reverseButtons: true
            # })
        'click .submit_post': ->
            kiosk = Docs.findOne model:'kiosk'
            Docs.update kiosk._id, 
                $set:
                    current_route:'checkin_edit'
                    current_doc_id:null
            
            Docs.update @_id,
                submitted:true
            # Router.go "/kiosk"
            Swal.fire({
                title: "thanks for your feedback"
                # title: "checked in"
                # text: "point bounty will be held "
                icon: 'success'
                timer:2000
                # background: 'green'
                timerProgressBar:true
                showClass: {popup: 'animate__animated animate__fadeInDown'}
                hideClass: {popup: 'animate__animated animate__fadeOutUp'}
                showConfirmButton:false
                # confirmButtonText: 'publish'
                # confirmButtonColor: 'green'
                # showCancelButton: true
                # cancelButtonText: 'cancel'
                # reverseButtons: true
            })

    Template.post_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        # @autorun => @subscribe 'current_kiosk_doc', Router.current().params.doc_id, ->
    Template.post_view.onRendered ->
        found_doc = Docs.findOne Router.current().params.doc_id
if Meteor.isServer
    Meteor.publish 'current_kiosk_doc', ->
        if Meteor.isDevelopment
            kiosk = 
                Docs.findOne 
                    model:'kiosk'
                    dev:true
        else 
            kiosk = 
                Docs.findOne 
                    model:'kiosk'
        Docs.find 
            _id:kiosk.current_doc_id
if Meteor.isClient
    Template.posts.events
        'click .add_post': ->
            new_id = 
                Docs.insert 
                    model:'post'
            Router.go "/post/#{new_id}/edit"
        'click .select_search': ->
            picked_tags.push @name
            Session.set('full_doc_id', null)
    
            $('#search').val('')
            Session.set('current_search', null)
    
    
    Template.posts.events
        'click .print_me': ->
    
        # # 'keyup #search': _.throttle((e,t)->
        'click #search': (e,t)->
            if picked_tags.array().length > 0
                Session.set('dummy', !Session.get('dummy'))
        'keydown #search': (e,t)->
            # query = $('#search').val()
            search = $('#search').val().trim().toLowerCase()
            # if query.length > 0
            Session.set('current_search', search)
            if search.length > 0
                if e.which is 13
                    if search.length > 0
                        # Session.set('searching', true)
                        picked_tags.push search
                        Session.set('full_doc_id',null)
                        Session.set('is_loading', true)
                        $('#search').val('')
                        $('#search').blur()
                        Session.set('current_search', null)
        # , 200)
    
        # 'keydown #search': _.throttle((e,t)->
        #     if e.which is 8
        #         search = $('#search').val()
        #         if search.length is 0
        #             last_val = picked_tags.array().slice(-1)
        #             $('#search').val(last_val)
        #             picked_tags.pop()
        #             Meteor.call 'search_reddit', picked_tags.array(), ->
        # , 1000)
    
        'click .reconnect': -> Meteor.reconnect()
    
        'click .toggle_tag': (e,t)-> picked_tags.push @valueOf()
        'click .print_me': (e,t)->
            
    Template.post_view.events 
        'click .get_comments':->
            Meteor.call 'get_comments', Router.current().params.doc_id, ->
                
    Template.post_view.helpers
        comment_docs: ->
            Docs.find 
                model:'comment'
                parent_id:Router.current().params.doc_id
    Template.posts.helpers
        porn_class: ->
            if Session.get('porn') then 'large red' else 'compact'
        full_doc_id: ->
            Session.get('full_doc_id')
        full_doc: ->
            Docs.findOne Session.get('full_doc_id')
        current_bg:->
            found = Docs.findOne {
                model:'post'
                tags:$in:picked_tags.array()
                "watson.metadata.image":$exists:true
                # thumbnail:$nin:['default','self']
            },sort:ups:-1
            if found
                found.watson.metadata.image
            # else 
    
        emotion_avg_result: ->
            Results.findOne 
                model:'emotion_avg'
        # in_dev: -> Meteor.isDevelopment()
        not_searching: ->
            picked_tags.array().length is 0 and Session.equals('current_search',null)
            
        search_class: ->
            if Session.get('current_search')
                'massive active' 
            else
                if picked_tags.array().length is 0
                    'big'
                else 
                    'big' 
              
                    
        curent_date_setting: -> Session.get('date_setting')
    
        term_icon: ->
        is_loading: -> Session.get('is_loading')
    
        tag_result_class: ->
            # ec = omega.emotion_color
            total_doc_result_count = Docs.find({}).count()
            percent = @count/total_doc_result_count
            whole = parseInt(percent*10)+1
    
            # if whole is 0 then "#{ec} f5"
            if whole is 0 then "f5"
            else if whole is 1 then "f11"
            else if whole is 2 then "f12"
            else if whole is 3 then "f13"
            else if whole is 4 then "f14"
            else if whole is 5 then "f15"
            else if whole is 6 then "f16"
            else if whole is 7 then "f17"
            else if whole is 8 then "f18"
            else if whole is 9 then "f19"
            else if whole is 10 then "f20"
    
        connection: ->
            Meteor.status()
        connected: -> Meteor.status().connected
    
        unpicked_tags: ->
            # # doc_count = Docs.find().count()
            # # if doc_count < 3
            # #     Tags.find({count: $lt: doc_count})
            # # else
            # unless Session.get('searching')
            #     unless Session.get('current_search').length > 0
            Results.find({model:'tag'})
    
        result_class: ->
            if Template.instance().subscriptionsReady()
                ''
            else
                'disabled'
    
        picked_tags: -> picked_tags.array()
    
        picked_tags_plural: -> picked_tags.array().length > 1
    
        searching: ->
            Session.get('searching')
    
        one_post: -> Docs.find().count() is 1
    
        two_posts: -> Docs.find().count() is 2
        three_posts: -> Docs.find().count() is 3
        four_posts: -> Docs.find().count() is 4
        more_than_four: -> Docs.find().count() > 4
        one_result: ->
            Docs.find().count() is 1
    
        docs: ->
            # if picked_tags.array().length > 0
            cursor =
                Docs.find {
                    model:'post'
                },
                    sort:
                        "#{Session.get('sort_key')}":Session.get('sort_direction')
            cursor
    
    
        home_subs_ready: ->
            Template.instance().subscriptionsReady()
            
        #     @autorun => Meteor.subscribe 'current_doc', Router.current().params.doc_id
        # Template.array_view.events
        #     'click .toggle_post_filter': ->
        #         value = @valueOf()
        #         current = Template.currentData()
                # match = Session.get('match')
                # key_array = match["#{current.key}"]
                # if key_array
                #     if value in key_array
                #         key_array = _.without(key_array, value)
                #         match["#{current.key}"] = key_array
                #         picked_tags.remove value
                #         Session.set('match', match)
                #     else
                #         key_array.push value
                #         picked_tags.push value
                #         Session.set('match', match)
                #         Meteor.call 'search_reddit', picked_tags.array(), ->
                #         # Meteor.call 'agg_idea', value, current.key, 'entity', ->
                #         # match["#{current.key}"] = ["#{value}"]
                # else
                # if value in picked_tags.array()
                #     picked_tags.remove value
                # else
                #     # match["#{current.key}"] = ["#{value}"]
                #     picked_tags.push value
                # # Session.set('match', match)
                # if picked_tags.array().length > 0
                #     Meteor.call 'search_reddit', picked_tags.array(), ->
    
        # Template.array_view.helpers
        #     values: ->
        #         Template.parentData()["#{@key}"]
        #
        #     post_label_class: ->
        #         match = Session.get('match')
        #         key = Template.parentData().key
        #         doc = Template.parentData(2)
        #         if @valueOf() in picked_tags.array()
        #             'active'
        #         else
        #             'basic'
        #         # if match["#{key}"]
        #         #     if @valueOf() in match["#{key}"]
        #         #         'active'
        #         #     else
        #         #         'basic'
        #         # else
        #         #     'basic'
        #
        
        

  
if Meteor.isServer 
    Meteor.publish 'product_counter', ()->
        Counts.publish this, 'product_counter', 
            Docs.find({
                model:'product'
            })
        return undefined    # otherwise coffeescript returns a Counts.publish
                          # handle when Meteor expects a Mongo.Cursor object.
        
        
    Meteor.publish 'post_tag_results', (
        picked_tags=null
        # query
        porn=false
        # searching
        dummy
        )->
    
        self = @
        match = {}
    
        match.model = 'post'
        # if query
        # if view_nsfw
        match.over_18 = porn
        if picked_tags and picked_tags.length > 0
            match.tags = $all: picked_tags
            limit = 10
            # else
            #     limit = 10
            #     match._timestamp = $gt:moment().subtract(1, 'days')
            # else /
                # match.tags = $all: picked_tags
            agg_doc_count = Docs.find(match).count()
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: "tags": 1 }
                { $unwind: "$tags" }
                { $group: _id: "$tags", count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $match: count: $lt: agg_doc_count }
                # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
                { $sort: count: -1, _id: 1 }
                { $limit: limit }
                { $project: _id: 0, name: '$_id', count: 1 }
            ], {
                allowDiskUse: true
            }
        
            tag_cloud.forEach (tag, i) =>
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    # index: i
            
            self.ready()
            # else []
    
    Meteor.publish 'tag_image', (
        term=null
        porn=false
        )->
        # added_tags = []
        # if picked_tags.length > 0
        #     added_tags = picked_tags.push(term)
        match = {
            model:'post'
            tags: $in: [term]
            # "watson.metadata.image": $exists:true
            # $where: "this.watson.metadata.image.length > 1"
        }
        # if porn
        # else 
        # added_tags = [term]
        # match = {model:'post'}
        # match.thumbnail = $nin:['default','self']
        # match.url = { $regex: /^.*(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png).*/, $options: 'i' }
        # found = Docs.findOne match
        # if found
        Docs.find match,{
            limit:1
            sort:
                points:-1
                ups:-1
            fields:
                image_id:1
                image_link:1
                model:1
                thumbnail:1
                tags:1
                ups:1
                over_18:1
                url:1
        }
        # else
        #     backup = 
        #         Docs.findOne 
        #             model:'post'
        #             thumbnail:$exists:true
        #             tags:$in:[term]
        #     if backup
        #         Docs.find { 
        #             model:'post'
        #             thumbnail:$exists:true
        #             tags:$in:[term]
        #         }, 
        #             limit:1
        #             sort:ups:1
    # Meteor.publish 'doc_results', (
    #     picked_tags=null
    #     sort_key='_timestamp'
    #     sort_direction=-1
    #     # dummy
    #     # current_query
    #     # date_setting
    #     )->
    #     # else
    #     self = @
    #     match = {model:'post'}
    #     # match.over_18 = $ne:true
    #     #         yesterday = now-day
    #     #         match._timestamp = $gt:yesterday
    #     # if porn
    #     # if picked_tags.length > 0
    #     #     # if picked_tags.length is 1
    #     #     #     found_doc = Docs.findOne(title:picked_tags[0])
    #     #     #
    #     #     #     match.title = picked_tags[0]
    #     #     # else
    #     if picked_tags and picked_tags.length > 0
    #         match.tags = $all: picked_tags
    #     else 
    #         match._timestamp = $gt:moment().subtract(1, 'days')
    #     Docs.find match,
    #         sort:
    #             "#{sort_key}":sort_direction
    #             points:-1
    #             ups:-1
    #         limit:20
        # else 
        #     Docs.find match,
        #         sort:_timestamp:-1
        #         limit:10
    
    
    
    # Meteor.publish 'overlap', (
    #     username1
    #     username2
    #     picked_tags=null
    #     # query
    #     porn=false
    #     # searching
    #     dummy
    #     )->
    
    #     self = @
    #     match = {}
    #     user1 = Meteor.users.findOne username:username1
    #     user2 = Meteor.users.findOne username:username2
    #     match.model = 'post'
    #     # if query
    #     # if view_nsfw
    #     match.upvoter_ids = $all:[user1._id,user2._id]
    #     # match.over_18 = porn
    #     if picked_tags and picked_tags.length > 0
    #         match.tags = $all: picked_tags
    #         limit = 10
    #     else
    #         limit = 20
    #     # else /
    #         # match.tags = $all: picked_tags
    #     agg_doc_count = Docs.find(match).count()
    #     tag_cloud = Docs.aggregate [
    #         { $match: match }
    #         { $project: "tags": 1 }
    #         { $unwind: "$tags" }
    #         { $group: _id: "$tags", count: $sum: 1 }
    #         { $match: _id: $nin: picked_tags }
    #         { $match: count: $lt: agg_doc_count }
    #         # { $match: _id: {$regex:"#{current_query}", $options: 'i'} }
    #         { $sort: count: -1, _id: 1 }
    #         { $limit: limit }
    #         { $project: _id: 0, name: '$_id', count: 1 }
    #     ], {
    #         allowDiskUse: true
    #     }
    
    #     tag_cloud.forEach (tag, i) =>
    #         self.added 'results', Random.id(),
    #             name: tag.name
    #             count: tag.count
    #             model:'overlap_tag'
    #             # index: i
        
    #     self.ready()
    #     # else []
if Meteor.isClient
    Template.post_view.onCreated ->
        @autorun => @subscribe 'related_group',Router.current().params.doc_id, ->
    Template.post_view.onCreated ->
        @autorun => @subscribe 'post_tips',Router.current().params.doc_id, ->
    Template.post_view.events 
        'click .pick_flat_tag': (e)-> 
            picked_tags.push @valueOf()
            # Session.set('full_doc_id', null)
            $(e.currentTarget).closest('.pick_flat_tag').transition('fly up', 500)
    
            Session.set('loading',true)
            Router.go "/posts"
        'click .get_comments': ->
                
                
if Meteor.isServer 
    Meteor.methods 
        find_tribe: (tribe_slug)->
            found = Docs.findOne 
                model:'tribe'
                slug:tribe_slug
            
            if found 
                return found._id
            else
                new_id = 
                    Docs.insert 
                        model:'tribe'
                        title:tribe_slug
                        slug:tribe_slug
                return new_id
                    
                            
                            
                            
                
if Meteor.isClient         
    Template.tip_button.events 
        'click .tip_post': ->
            new_id = 
                Docs.insert 
                    model:'transfer'
                    post_id:Router.current().params.doc_id
                    complete:true
                    amount:@amount
                    transfer_type:'tip'
                    tags:['tip']
            Meteor.call 'calc_user_points', ->
            $('body').toast(
                showIcon: 'coins'
                message: "post tipped #{amount} "
                showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )
                
                
if Meteor.isServer 
    Meteor.publish 'post_tips', (post_id)->
        Docs.find 
            model:'transfer'
            post_id:post_id