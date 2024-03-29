if Meteor.isClient
    Router.route '/products/', (->
        @layout 'layout'
        @render 'products'
        ), name:'products'
    Router.route '/product/:doc_id', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'
    
    Template.products.onCreated ->
        @autorun => Meteor.subscribe 'product_counter', ->
    Template.products.events 
        'click .add_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    source:'local'
            Router.go "/product/#{new_id}/edit"
    Template.products.helpers
        product_count: -> Counts.get('product_counter') 

    
if Meteor.isServer
    Meteor.publish 'model_counter', (model)->
        if model 
            Counts.publish this, 'model_counter', 
                Docs.find({
                    model:model
                })
            return undefined

if Meteor.isClient 
    Template.product_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.product_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => @subscribe 'product_orders', Router.current().params.doc_id, ->
    Template.products.onCreated ->
        document.title = 'gr shop'
        # window.speechSynthesis.speak new SpeechSynthesisUtterance 'gr shop'
        
        # @autorun => @subscribe 'model_docs','artist', ->
        @autorun => @subscribe 'product_facets',
            picked_tags.array()
            Session.get('picked_source')
            Session.get('product_search')
        @autorun => @subscribe 'product_results',
            picked_tags.array()
            Session.get('picked_source')
            Session.get('product_search')

    Template.product_view.onRendered ->
        found_doc = Docs.findOne Router.current().params.doc_id
        if found_doc 
            unless found_doc.details 
                Meteor.call 'product_details', Router.current().params.doc_id, ->
                
    Template.product_view.helpers
        split_ingredient_list: ->
            @ingredientList.split ','
        instruction_steps: ->
            @details.analyzedInstructions[0].steps
            
if Meteor.isServer
    Meteor.publish 'product_orders', (product_id)->
        Docs.find
            model:'order'
            product_id:product_id
if Meteor.isClient
    Template.product_orders.helpers 
        product_order_docs: ->
            Docs.find 
                model:'order'
                product_id:Router.current().params.doc_id
    Template.product_view.events
        'click .pick_product_tag': ->
            picked_tags.push @valueOf()
            Router.go "/products"
            
        'click .quickbuy': ->
            if confirm 'quickbuy?'
                Meteor.users.update Meteor.userId(), 
                    $inc:
                        points:-@price_points
                new_id = 
                    Docs.insert 
                        model:'order'
                        product_id:Router.current().params.doc_id
                        status:'complete'
                        order_amount:@price_points 
                Router.go "/order/#{new_id}/"
            
            
if Meteor.isClient
    Template.product_item.onCreated ->
        # @autorun => Meteor.subscribe 'model_docs', 'food'
    Template.product_item.events
        'click .quickbuy': ->
            Session.set('quickbuying_id', @_id)
            # $('.ui.dimmable')
            #     .dimmer('show')
            # $('.special.cards .image').dimmer({
            #   on: 'hover'
            # });
            # $('.card')
            #   .dimmer('toggle')
            $('.ui.modal')
              .modal('show')

        'click .goto_food': (e,t)->
            # $(e.currentTarget).closest('.card').transition('zoom',420)
            # $('.global_container').transition('scale', 500)
            Router.go("/food/#{@_id}")
            # Meteor.setTimeout =>
            # , 100

        # 'click .view_item': ->
        #     $('.container_')

    Template.product_item.helpers
        product_item_class: ->
            # if Session.get('quickbuying_id')
            #     if Session.equals('quickbuying_id', @_id)
            #         'raised'
            #     else
            #         'active medium dimmer'
        is_quickbuying: ->
            Session.equals('quickbuying_id', @_id)

        food: ->
            Docs.find {
                model:'food'
            }, sort:title:1
        
        
        
    Template.product_item.events
        'click .add_to_cart': (e,t)->
            $(e.currentTarget).closest('.card').transition('bounce',500)
            Meteor.call 'add_to_cart', @_id, =>
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{@title} added"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom center"
                )
            
            
            
    Template.products.helpers
        product_docs: ->
            Docs.find {
                model:'product'
            }, sort:_timestamp:-1
            
        picked_tags: -> picked_tags.array()
        tag_results: ->
            Results.find()
        
    Template.products.events 
        'click .pick_tag': ->
            picked_tags.push @name
            $('body').toast({
                title: "searching #{@name}"
                # message: 'Please see desk staff for key.'
                class : 'info'
                showIcon:'hashtag'
                # showProgress:'bottom'
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
            
            Meteor.call 'call_product', @name, (err,res)->
                $('body').toast({
                    title: "#{res} search complete"
                    # message: 'Please see desk staff for key.'
                    class : 'success'
                    showIcon:'hashtag'
                    # showProgress:'bottom'
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
                
            
        'click .unpick_tag': ->
            picked_tags.remove @valueOf()
        
        'keyup .product_search': (e,t)->
            query = t.$('.product_search').val()
            Session.set('product_search',query)
            if e.which is 13
                Meteor.call 'call_product', Session.get('product_search'), ->

            
        'keyup .menu_search': (e,t)->
            query = t.$('.menu_search').val()
            Session.set('menu_search',query)
            if e.which is 13
                Meteor.call 'search_menu', Session.get('menu_search'), ->

            
            
if Meteor.isServer
    Meteor.publish 'product_facets', (
        picked_tags=[]
        picked_source='local'
        title_search=''
        )->
    
            self = @
            match = {}
    
            # match.tags = $all: picked_tags
            match.model = $in:['product']
            match.source = picked_source
            # if parent_id then match.parent_id = parent_id
    
            # if view_private is true
            #     match.author_id = Meteor.userId()
            if title_search.length > 1
                match.title = {$regex:"#{title_search}", $options: 'i'}

            # if view_private is false
            #     match.published = $in: [0,1]
    
            if picked_tags.length > 0 then match.tags = $all: picked_tags

            total_count = Docs.find(match).count()
            tag_cloud = Docs.aggregate [
                { $match: match }
                { $project: tags: 1 }
                { $unwind: "$tags" }
                { $group: _id: '$tags', count: $sum: 1 }
                { $match: _id: $nin: picked_tags }
                { $sort: count: -1, _id: 1 }
                { $match: count: $lt: total_count }
                { $limit: 20 }
                { $project: _id: 0, name: '$_id', count: 1 }
                ]
            tag_cloud.forEach (tag, i) ->
                self.added 'results', Random.id(),
                    name: tag.name
                    count: tag.count
                    model:'tag'
                    index: i
                    
            self.ready()

    Meteor.publish 'product_results', (
        picked_tags=[]
        picked_source='local'
        title_search=''
        )->
        self = @
        match = {}
        match.model = $in:['product']
        match.source = picked_source

        if picked_tags.length > 0 then match.tags = $all: picked_tags
        if title_search.length > 1
            match.title = {$regex:"#{title_search}", $options: 'i'}
        #     # match.tags_string = {$regex:"#{query}", $options: 'i'}
    
        # unless Meteor.userId()
        #     match.private = $ne:true
            
        
        Docs.find match,
            sort:_timestamp:-1
            limit:10
            # fields: 
            #     strArtistFanart:1
            #     strArtistThumb:1
            #     strArtistLogo:1
            #     strArtist:1
            #     strGenre:1
            #     strStyle:1
            #     strMood:1
            #     _timestamp:1
            #     model:1
            #     tags:1