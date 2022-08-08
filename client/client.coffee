@picked_tags = new ReactiveArray []
@picked_user_tags = new ReactiveArray []
@picked_location_tags = new ReactiveArray []
@picked_timestamp_tags = new ReactiveArray []
@picked_buildings = new ReactiveArray []
@picked_units = new ReactiveArray []



Tracker.autorun ->
    current = Router.current()
    Tracker.afterFlush ->
        $(window).scrollTop 0
Meteor.startup ->
    process.env.TZ='America/Denver'
    moment().calendar null,
        sameDay: '[today]'
        nextDay: '[tomorrow]'
        nextWeek: 'dddd'
        lastDay: '[yesterday]'
        lastWeek: '[last] dddd'
        sameElse: 'DD/MM/YYYY'
    


# Meteor.users.find(_id:Meteor.userId()).observe({
#     changed: (new_doc, old_doc)->
#         # console.log 'changed', new_doc.points, old_doc.points
#         difference = new_doc.points-old_doc.points
#         if difference > 0
#             $('body').toast({
#                 title: "#{new_doc.points-old_doc.points}p earned"
#                 # message: 'Please see desk staff for key.'
#                 class : 'success'
#                 showIcon:'hashtag'
#                 # showProgress:'bottom'
#                 position:'bottom right'
#                 # className:
#                 #     toast: 'ui massive message'
#                 # displayTime: 5000
#                 transition:
#                   showMethod   : 'zoom',
#                   showDuration : 250,
#                   hideMethod   : 'fade',
#                   hideDuration : 250
#                 })

# })
    
    
    
# Docs.find({model:'log',read_user_ids:$nin:[Meteor.userId()]}).observe({
# Docs.find({model:'log',read_user_ids:{$nin:[Meteor.userId()]}}).observe({
#     added: (new_doc)->
#         console.log 'alert', new_doc
#         # difference = new_doc.points-old_doc.points
#         # author = Meteor.users.findOne new_doc._author_id
#         # Meteor.call "c.get_download_url", author.image_id,(err,download_url) ->
#         #     console.log "Upload Error: #{err}"
#         #     console.log "#{download_url}"

#         # if difference > 0
#         $('body').toast({
#             title: "#{new_doc.body}"
#             # showImage:"{{c.url currentUser.image_id width=300 height=300 gravity='face' crop='fill'}}"
#             # classImage: 'avatar',
#             message: "#{moment(new_doc._timestamp).fromNow()}"
#             displayTime: 0,
#             class: 'black',
#             # classActions: 'ui fluid',
#             actions: [{
#                 text: 'mark read +1p'
#                 class: 'ui fluid green button'
#                 click: ()->
#                     Docs.update new_doc._id,
#                         $addToSet:
#                             read_user_ids:Meteor.userId()

#                     # $('body').toast({message:'You clicked "yes", toast closes by default'})
#             }]
#             showIcon:'bell'
#             # showProgress:'bottom'
#             position:'bottom right'
#             # className:
#             #     toast: 'ui massive message'
#             # displayTime: 5000
#             transition:
#                 showMethod   : 'zoom',
#                 showDuration : 250,
#                 hideMethod   : 'zoom',
#                 hideDuration : 250
#         })
# })
    
    
    
Template.footer.helpers
    all_users: -> Meteor.users.find()
    all_docs: -> Docs.find()
    result_docs: -> Results.find()



Template.layout.events
    'click .fly_down': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly right', 500)
        $(e.currentTarget).closest('.grid').transition('fade down', 500)
    'click .fly_up': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly right', 500)
        $(e.currentTarget).closest('.grid').transition('fade up', 500)
    'click .fly_left': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly left', 500)
        $(e.currentTarget).closest('.grid').transition('fade left', 500)
    'click .fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly right', 500)
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .card_fly_right': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly right', 500)
        $(e.currentTarget).closest('.card').transition('fade right', 500)
    'click .zoom': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly right', 500)
        $(e.currentTarget).closest('.grid').transition('fade right', 500)
    'click .flip': (e,t)->
        # console.log 'hi'
        $(e.currentTarget).closest('.item').transition('fly right', 500)
        $(e.currentTarget).closest('.grid').transition('flip', 500)
        
    # 'click a': ->
    #     $('.global_container')
    #     .transition('fade out', 200)
    #     .transition('fade in', 200)
