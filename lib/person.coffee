if Meteor.isClient
    Template.persons.onCreated ->
        document.title = 'gr persons'
        
        Session.setDefault('current_search', null)
        Session.setDefault('is_loading', false)
        @autorun => @subscribe 'doc_by_id', Session.get('full_doc_id'), ->
        @autorun => @subscribe 'agg_emotions',
            picked_tags.array()
        @autorun => @subscribe 'person_tag_results',
            picked_tags.array()
            
    Template.persons.onCreated ->
        @autorun => @subscribe 'model_docs', 'person', ->
        @autorun => @subscribe 'persons',
            picked_tags.array()
            # Session.get('dummy')
    
    
    
    Router.route '/person/:doc_id', (->
        @layout 'layout'
        @render 'person_view'
        ), name:'person_view'
    Router.route '/person/:doc_id/edit', (->
        @layout 'layout'
        @render 'person_edit'
        ), name:'person_edit'
    Router.route '/persons', (->
        @layout 'layout'
        @render 'persons'
        ), name:'persons'
    Template.persons.onCreated ->
        @autorun => Meteor.subscribe 'model_counter',('person'), ->
            
    Template.person_edit.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
    Template.person_view.onCreated ->
        @autorun => @subscribe 'doc_by_id', Router.current().params.doc_id, ->
        @autorun => @subscribe 'child_docs', Router.current().params.doc_id, ->
            
            
    Template.persons.helpers
        total_person_count: -> Counts.get('model_counter') 
        person_docs: ->
            Docs.find 
                model:'person'
    Template.persons.events 
        'click .new_person': ->
            new_id = 
                Docs.insert 
                    model:'person'
                    complete:false
            Router.go "/person/#{new_id}/edit"