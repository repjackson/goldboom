# if Meteor.isClient
#     Template.rules_signing.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'user_by_username', Router.current().params.doc_id

#     Template.rules_signing.helpers
#         signing_doc: -> Docs.findOne Router.current().params.doc_id
#         agree_class: -> if @agree then 'green' else 'basic'
#         resident_email: ->
#             res = Meteor.users.findOne
#                 username:@resident
#             res.emails[0].address

#     Template.rules_signing.events
#         'click .confirm_email':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             email_value = $('.email_value').val('')

#             if signing_doc.agree
#                 Docs.update signing_doc._id,
#                     $set:email_confirmed:false
#             else
#                 Docs.update signing_doc._id,
#                     $set:email_confirmed:true

#         'click .agree':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             if signing_doc.agree
#                 Docs.update signing_doc._id,
#                     $set:agree:false
#             else
#                 Docs.update signing_doc._id,
#                     $set:agree:true

#         'click .edit_signature':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             Docs.update signing_doc._id,
#                 $set:signature_saved:false


#         'click .submit_rules':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             user = Meteor.users.findOne username:signing_doc.resident
#             Meteor.users.update user._id,
#                 $set:rules_signed:true
#             Meteor.call 'send_rules_regs_receipt_email', user._id
#             Meteor.call 'run_user_checks', user
#             # Session.set 'displaying_profile', user._id
#             Router.go "/healthclub_session/#{signing_doc.session_id}"

#     Template.guidelines_signing.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
#         @autorun => Meteor.subscribe 'user_by_username', Router.current().params.doc_id

#     Template.guidelines_signing.helpers
#         signing_doc: -> Docs.findOne Router.current().params.doc_id
#         agree_class: -> if @agree then 'green' else 'basic'
#         resident_email: ->
#             res = Meteor.users.findOne
#                 username:@resident
#             res.emails[0].address

#     Template.guidelines_signing.events
#         'click .confirm_email':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             email_value = $('.email_value').val('')

#             if signing_doc.agree
#                 Docs.update signing_doc._id,
#                     $set:email_confirmed:false
#             else
#                 Docs.update signing_doc._id,
#                     $set:email_confirmed:true

#         'click .agree':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             if signing_doc.agree
#                 Docs.update signing_doc._id,
#                     $set:agree:false
#             else
#                 Docs.update signing_doc._id,
#                     $set:agree:true

#         'click .edit_signature':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             Docs.update signing_doc._id,
#                 $set:signature_saved:false


#         'click .submit_guidelines':->
#             signing_doc = Docs.findOne Router.current().params.doc_id
#             user = Meteor.users.findOne username:signing_doc.resident
#             Meteor.users.update user._id,
#                 $set:member_waiver_signed:true
#             # Meteor.call 'send_rules_regs_receipt_email', user._id
#             Meteor.call 'run_user_checks', user
#             # Session.set 'displaying_profile', user._id
#             Router.go "/healthclub_session/#{signing_doc.session_id}"




#     Template.rules_and_regs_check.onCreated ->
#         @autorun => Meteor.subscribe 'rules_signed_username', @data.username
#     Template.rules_and_regs_check.helpers
#         rules_signed: ->
#             Docs.findOne
#                 model:'rules_and_regs_signing'
#                 resident:@username
#     Template.rules_and_regs_check.events
#         'click .sign_rules': ->
#             new_id = Docs.insert
#                 model:'rules_and_regs_signing'
#                 resident: @username
#             Router.go "/sign_rules/#{new_id}/#{@username}"
#             Session.set 'displaying_profile',null



#     Template.member_guidelines_check.onCreated ->
#         @autorun => Meteor.subscribe 'member_guidelines_username', @data.username
#     Template.member_guidelines_check.helpers
#         guidelines_signed: ->
#             Docs.findOne
#                 model:'member_guidelines_signing'
#                 resident:@username
#     Template.member_guidelines_check.events
#         'click .sign_guidelines': ->
#             new_id = Docs.insert
#                 model:'member_guidelines_signing'
#                 resident: @username
#             Router.go "/sign_guidelines/#{new_id}/#{@username}"
#             # Session.set 'displaying_profile',null




#     Template.add_guest.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Router.current().params.new_guest_id
#         @autorun => Meteor.subscribe 'session_from_guest_id', Router.current().params.new_guest_id
#         @autorun => Meteor.subscribe 'resident', Router.current().params.new_guest_id
#     Template.add_guest.helpers
#         new_guest_doc: -> Docs.findOne Router.current().params.new_guest_id

#     Template.add_guest.events
#         'click .submit_new_guest': ->

#         'click .cancel_new_guest': ->
#             guest_doc = Docs.findOne Router.current().params.new_guest_id
#             Docs.remove guest_doc._id
#             Session.set 'displaying_profile', guest_doc.resident_id
#             Router.go "/healthclub_session/#{guest_doc.session_id}"

#             $('body').toast({
#                 title: "Adding guest canceled."
#                 class: 'info'
#                 transition:
#                     showMethod   : 'zoom',
#                     showDuration : 100,
#                     hideMethod   : 'fade',
#                     hideDuration : 100
#             })

#         'click .agree':->
#             guest_doc = Docs.findOne Router.current().params.new_guest_id
#             if guest_doc.agree
#                 Docs.update guest_doc._id,
#                     $set:agree:false
#             else
#                 Docs.update guest_doc._id,
#                     $set:agree:true

#         'click .edit_signature':->
#             signing_doc = Docs.findOne Router.current().params.new_guest_id
#             Docs.update signing_doc._id,
#                 $set:signature_saved:false


#         'click .submit_guest':->
#             guest_doc = Docs.findOne Router.current().params.new_guest_id
#             checking_in_doc = Docs.findOne guest_doc.session_id

#             Docs.update checking_in_doc._id,
#                 $addToSet: guest_ids: guest_doc._id

#             user = Meteor.users.findOne guest_doc.resident_id
#             Meteor.users.update user._id,
#                 $addToSet:guest_ids: guest_doc._id

#             # Session.set 'displaying_profile', guest_doc.resident_id
#             Router.go "/healthclub_session/#{guest_doc.session_id}"





#     Template.download_rules_pdf.onCreated ->
#         @autorun => Meteor.subscribe 'user_by_username', Router.current().params.username
#         @autorun => Meteor.subscribe 'document_by_slug', 'rules_regs'

#     Template.download_rules_pdf.helpers
#         downloading_user: ->
#             Meteor.users.findOne username:Router.current().params.username


#     Template.download_rules_pdf.events
#         'click .download_rules_pdf': ->
#             signing_doc = Docs.findOne model:'rules_and_regs_signing'
#             Meteor.call 'generate_rules_pdf', signing_doc._id



# if Meteor.isServer
#     Meteor.publish 'user_by_username', (username)->
#         Meteor.users.find
#             username:username

#     Meteor.publish 'user_by_user_id', (user_id)->
#         Meteor.users.find user_id


#     Meteor.publish 'session_from_guest_id', (guest_id)->
#         guest_doc = Docs.findOne guest_id
#         Docs.find
#             _id:guest_doc.session_id
            
            
# if Meteor.isClient
#     Template.user_check_steps.onCreated ->
#         @autorun => Meteor.subscribe 'model_docs', 'user_check'
#     Template.user_check_steps.helpers
#         user_check: ->
#             Docs.find
#                 model:'user_check'

#         user_check_completed: ->
#             if Meteor.user().roles
#                 if 'dev' in Meteor.user().roles
#                     false
#                 else
#                     context_user = Template.parentData()
#                     check = Template.currentData()
#                     context_user["#{check.slug}"]
#                     # console.log @slug

#         checkins_left_without_email_verification: ->
#             6-@checkins_without_email_verification

#         checkins_left_without_gov_id: ->
#             6-@checkins_without_gov_id


#     Template.user_check_steps.events
#         'click .recheck': (e,t)->
#             $(e.currentTarget).closest('.recheck').transition('pulse')
#             context_user = Template.currentData()
#             console.log context_user
#             # username = Template.parentData().resident_username
#             Meteor.call @slug, context_user, (err,res)=>
#                 # Meteor.users.update context_user._id,
#                 #     $set: "#{@slug}":res


# if Meteor.isServer
#     Meteor.methods
#         run_user_checks:(user)->
#             # console.log 'running user checks for', user.username
#             user_checks_docs = Docs.find(model:'user_check')
#             # console.log 'count', user_checks_docs.count()
#             for user_check in user_checks_docs.fetch()
#                 # console.log user
#                 console.log 'user_check', user_check.slug
#                 Meteor.call "#{user_check.slug}", user, (err,res)=>
#                     # console.log 'check',user_check.slug,'res',res
#             #         Meteor.users.update user._id,
#             #             $set: "#{user_check.slug}":res
#         image_check: (user)->
#             if user.kiosk_photo
#                 Meteor.users.update user._id,
#                     $set:
#                         image_check:true
#                     $unset:
#                         checkins_without_image:1
#             else
#                 Meteor.users.update user._id,
#                     $inc:checkins_without_image:1
#                 updated_user = Meteor.users.findOne user._id
#                 if updated_user.checkins_without_image > 3
#                     Meteor.users.update user._id,
#                         $set: red_flagged:true

#         rules_and_regulations_signed: (user)->
#             console.log 'checking rules and regs for ', user.username
#             found_rules_signing = Docs.findOne
#                 model:'rules_and_regs_signing'
#                 resident:user.username
#                 signature_saved:true
#             # console.log 'found rules signing', found_rules_signing
#             check_value = if found_rules_signing then true else false
#             Meteor.users.update user._id,
#                 $set:rules_and_regulations_signed:check_value

#         member_waiver_signed: (user)->
#             console.log 'checking member waiver for ', user.username
#             found_member_signing = Docs.findOne
#                 model:'member_guidelines_signing'
#                 resident:user.username
#             # console.log 'found member signing', found_member_signing
#             check_value = if found_member_signing then true else false
#             Meteor.users.update user._id,
#                 $set:found_member_signing:check_value

#         email_verified: (user)->
#             if user.emails and user.emails[0].verified
#                 console.log 'email verification', user.emails[0].verified
#                 Meteor.users.update user._id,
#                     $set:
#                         email_verified:true
#                         email_red_flagged:false
#                     $unset:checkins_without_email_verification:1
#             else
#                 Meteor.users.update user._id,
#                     $set:email_verified:false
#         staff_government_id_check: (user)->
#             console.log 'running staff gov id check', user.username
#             if user.staff_verifier
#                 Meteor.users.update user._id,
#                     $set:staff_government_id_check:true
#                     $unset:
#                         checkins_without_gov_id:1
#                         gov_red_flagged:1
#         residence_paperwork: (user)->
#             console.log 'running residence paperwork', user.username
#             if user.owner
#                 if user.ownership_paperwork
#                     Meteor.users.update user._id,
#                         $set:residence_paperwork:true
#             else
#                 if user.lease_agreement
#                     Meteor.users.update user._id,
#                         $set:residence_paperwork:true