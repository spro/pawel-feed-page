window.slugify  = (s) -> s.toLowerCase().replace /\W+/g, '-'

window.StoredStateMixin =

    setStoredState: (cb) ->
        @setState @getStoredState(), cb

