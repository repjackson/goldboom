Meteor.publish 'facet_sub', (
    model=null
    picked_tags
    title_search=''
    picked_timestamp_tags
    # picked_author_ids=[]
    # picked_location_tags
    # picked_building_tags
    # picked_unit_tags
    # author_id
    # parent_id
    # tag_limit
    # doc_limit
    # sort_object
    # view_private
    )->

        self = @
        match = {}

        # match.tags = $all: picked_tags
        match.model = model
        # if parent_id then match.parent_id = parent_id

        # if view_private is true
        #     match.author_id = Meteor.userId()

        # if view_private is false
        #     match.published = $in: [0,1]

        if title_search.length > 1
            match.title = {$regex:"#{title_search}", $options: 'i'}

        if picked_tags.length > 0 then match.tags = $all: picked_tags

        # if picked_author_ids.length > 0
        #     match.author_id = $in: picked_author_ids
        #     match.published = 1
        # if picked_location_tags.length > 0 then match.location_tags = $all: picked_location_tags
        # if picked_building_tags.length > 0 then match.building_tags = $all: picked_building_tags
        if picked_timestamp_tags.length > 0 then match._timestamp_tags = $all: picked_timestamp_tags

        # if tag_limit then limit=tag_limit else limit=50
        # if author_id then match.author_id = author_id
        match.published = true

        # if view_private is true then match.author_id = @userId
        # if view_resonates?
        #     if view_resonates is true then match.favoriters = $in: [@userId]
        #     else if view_resonates is false then match.favoriters = $nin: [@userId]
        # if view_read?
        #     if view_read is true then match.read_by = $in: [@userId]
        #     else if view_read is false then match.read_by = $nin: [@userId]
        # if view_published is true
        #     match.published = $in: [1,0]
        # else if view_published is false
        #     match.published = -1
        #     match.author_id = Meteor.userId()

        # if view_bookmarked?
        #     if view_bookmarked is true then match.bookmarked_ids = $in: [@userId]
        #     else if view_bookmarked is false then match.bookmarked_ids = $nin: [@userId]
        # if view_complete? then match.complete = view_complete



        # match.site = Meteor.settings.public.site

        # if view_images? then match.components?.image = view_images

        # lightbank models
        # if view_lightbank_type? then match.lightbank_type = view_lightbank_type
        # match.lightbank_type = $ne:'journal_prompt'

        # ancestor_ids_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: ancestor_array: 1 }
        #     { $unwind: "$ancestor_array" }
        #     { $group: _id: '$ancestor_array', count: $sum: 1 }
        #     { $match: _id: $nin: picked_ancestor_ids }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # ancestor_ids_cloud.forEach (ancestor_id, i) ->
        #     self.added 'ancestor_ids', Random.id(),
        #         name: ancestor_id.name
        #         count: ancestor_id.count
        #         index: i
        total_count = Docs.find(match).count()
        tag_cloud = Docs.aggregate [
            { $match: match }
            { $project: tags: 1 }
            { $unwind: "$tags" }
            { $group: _id: '$tags', count: $sum: 1 }
            { $match: _id: $nin: picked_tags }
            { $sort: count: -1, _id: 1 }
            { $match: count: $lt: total_count }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        tag_cloud.forEach (tag, i) ->
            self.added 'results', Random.id(),
                name: tag.name
                count: tag.count
                model:'tag'
                index: i

        # 
        #
        # # watson_keyword_cloud = Docs.aggregate [
        # #     { $match: match }
        # #     { $project: watson_keywords: 1 }
        # #     { $unwind: "$watson_keywords" }
        # #     { $group: _id: '$watson_keywords', count: $sum: 1 }
        # #     { $match: _id: $nin: picked_tags }
        # #     { $sort: count: -1, _id: 1 }
        # #     { $limit: limit }
        # #     { $project: _id: 0, name: '$_id', count: 1 }
        # #     ]
        # # watson_keyword_cloud.forEach (keyword, i) ->
        # #     self.added 'watson_keywords', Random.id(),
        # #         name: keyword.name
        # #         count: keyword.count
        # #         index: i
        #
        timestamp_tags_cloud = Docs.aggregate [
            { $match: match }
            { $project: _timestamp_tags: 1 }
            { $unwind: "$_timestamp_tags" }
            { $group: _id: '$_timestamp_tags', count: $sum: 1 }
            # { $match: _id: $nin: picked_timestamp_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]
        timestamp_tags_cloud.forEach (timestamp_tag, i) ->
            self.added 'results', Random.id(),
                name: timestamp_tag.name
                count: timestamp_tag.count
                model:'timestamp_tag'
                index: i
        
        #
        # building_tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: building_tags: 1 }
        #     { $unwind: "$building_tags" }
        #     { $group: _id: '$building_tags', count: $sum: 1 }
        #     { $match: _id: $nin: picked_building_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # building_tag_cloud.forEach (building_tag, i) ->
        #     self.added 'building_tags', Random.id(),
        #         name: building_tag.name
        #         count: building_tag.count
        #         index: i
        #
        #
        # location_tag_cloud = Docs.aggregate [
        #     { $match: match }
        #     { $project: location_tags: 1 }
        #     { $unwind: "$location_tags" }
        #     { $group: _id: '$location_tags', count: $sum: 1 }
        #     { $match: _id: $nin: picked_location_tags }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: limit }
        #     { $project: _id: 0, name: '$_id', count: 1 }
        #     ]
        # location_tag_cloud.forEach (location_tag, i) ->
        #     self.added 'location_tags', Random.id(),
        #         name: location_tag.name
        #         count: location_tag.count
        #         index: i
        #
        #
        # author_match = match
        # author_match.published = 1
        #
        # author_tag_cloud = Docs.aggregate [
        #     { $match: author_match }
        #     { $project: _author_id: 1 }
        #     { $group: _id: '$_author_id', count: $sum: 1 }
        #     { $match: _id: $nin: picked_author_ids }
        #     { $sort: count: -1, _id: 1 }
        #     { $limit: limit }
        #     { $project: _id: 0, text: '$_id', count: 1 }
        #     ]
        #
        #
        #
        # # author_objects = []
        # # Docs.find _id: $in: author_tag_cloud.
        #
        # author_tag_cloud.forEach (author_id) ->
        #     self.added 'author_ids', Random.id(),
        #         text: author_id.text
        #         count: author_id.count

        # found_docs = Docs.find(match).fetch()
        # found_docs.forEach (found_doc) ->
        #     self.added 'docs', doc._id, fields
        #         text: author_id.text
        #         count: author_id.count

        # doc_results = []
        # int_doc_limit = parseInt doc_limit
        # subHandle = Docs.find(match, {limit:20, sort: timestamp:-1}).observeChanges(
        #     added: (id, fields) ->
        #         # doc_results.push id
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         # doc_results.pull id
        #         self.removed 'docs', id
        # )

        # for doc_result in doc_results

        # user_results = Docs.find(_id:$in:doc_results).observeChanges(
        #     added: (id, fields) ->
        #         self.added 'docs', id, fields
        #     changed: (id, fields) ->
        #         self.changed 'docs', id, fields
        #     removed: (id) ->
        #         self.removed 'docs', id
        # )




        self.ready()

        # self.onStop ()-> subHandle.stop()

# Meteor.publish 'ancestor_id_docs', (ancestor_ids)->
#     # Docs.find
#     #     _id: $in: ancestor_ids




Meteor.publish 'model_docs', (model, limit=100)->
    Docs.find {
        model:model
    }, 
        limit:limit
        sort:
            _timestamp:-1
            
# Meteor.publish 'ancestor_ids', (doc_id, username)->
#     match = {}
#     self = @
#     if doc_id
#         # doc = Docs.findOne doc_id
#         match._id = doc_id
#     if username
#         user = Docs.findOne username:username
#         match.author_id = user._id

#     match.ancestor_array = $exists:true
#     # match._id = doc_id
#     # one_child = Docs.findOne(parent_id:doc_id)
#     # if one_child
#     #     match_array = one_child.ancestor_array
#     #     children = Docs.find(parent_id:one_child._id).fetch()
#     #     for child in children
#     #         match_array.push child._id
#     # else
#     #     match_array = doc.ancestor_array
#     # match.parent_id = $in:match_array

#     # if picked_ancestor_ids.length > 0 then match.ancestor_array = $all: picked_ancestor_ids
#     ancestor_ids_cloud = Docs.aggregate [
#         { $match: match }
#         { $project: ancestor_array: 1 }
#         { $unwind: "$ancestor_array" }
#         { $group: _id: '$ancestor_array', count: $sum: 1 }
#         # { $match: _id: $nin: picked_ancestor_ids }
#         { $sort: count: -1, _id: 1 }
#         { $limit: 10 }
#         { $project: _id: 0, name: '$_id', count: 1 }
#         ]
#     ancestor_ids_cloud.forEach (ancestor_id, i) ->
#         self.added 'ancestor_ids', Random.id(),
#             name: ancestor_id.name
#             count: ancestor_id.count
#             index: i

#     ancestor_doc_ids =  _.pluck ancestor_ids_cloud, 'name'

#     # if username
#     subHandle = Docs.find( {_id:$in:ancestor_doc_ids}, {limit:20, sort: timestamp:-1}).observeChanges(
#         added: (id, fields) ->
#             # doc_results.push id
#             self.added 'docs', id, fields
#         changed: (id, fields) ->
#             self.changed 'docs', id, fields
#         removed: (id) ->
#             # doc_results.pull id
#             self.removed 'docs', id
#     )

#     self.ready()

#     self.onStop ()-> subHandle.stop()


# # Meteor.publish 'parent_ids', (username, picked_parent_id)->
# #         parent_tag_cloud = Docs.aggregate [
# #             { $match: author_id:Meteor.userId() }
# #             { $project: parent_id: 1 }
# #             # { $unwind: "$tags" }
# #             { $group: _id: '$parent_id', count: $sum: 1 }
# #             { $match: _id: $nin: picked_tags }
# #             { $sort: count: -1, _id: 1 }
# #             { $limit: limit }
# #             { $project: _id: 0, name: '$_id', count: 1 }
# #             ]
# #         parent_tag_cloud.forEach (tag, i) ->
# #             self.added 'tags', Random.id(),
# #                 name: tag.doc_id
# #                 count: tag.count
# #                 index: i



Meteor.publish 'facet_doc', (tags)->
    split_array = tags.split ','
    Docs.find
        tags: split_array


Meteor.publish 'inline_doc', (slug)->
    Docs.find
        model:'inline_doc'
        slug:slug
Meteor.publish 'staff_users', ()->
    Meteor.users.find
        is_staff:true

