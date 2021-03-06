module.exports = class JsPath

  primTypes = /^(string|number|boolean)$/

  ###
  @constructor.
  @signature: new JsPath(path, val)
  @param: path - a dot-notation style "path" to identify a
    nested JS object.
  @description: Initialize a new js object with the provided
    path.  I've never actually used this constructor for any-
    thing, and it is here for the sake of "comprehensiveness"
    at this time, although I am incredulous as to it's overall
    usefulness.
  ###

  constructor:(path, val)->

    return JsPath.setAt {}, path, val or {}

  [
    'forEach','indexOf','join','pop','reverse'
    'shift','sort','splice','unshift','push'
  ].forEach (method)=>
    @[method+'At'] = (obj, path, rest...)=>
      target = @getAt obj, path
      if 'function' is typeof target?[method] then return target[method] rest...
      else throw new Error "Does not implement method #{method} at #{path}"


  ###
  @method. property of the constructor.
  @signature: JsPath.getAt(ref, path)
  @param: ref - the object to traverse.
  @param: path - a dot-notation style "path" to identify a
    nested JS object.
  @return: the object that can be found inside ref at the path
    described by the second parameter or undefined if the path
    is not valid.
  ###

  @getAt =(ref, path)->

    if 'function' is typeof path.split # ^1
      path = path.split '.'
    else
      path = path.slice()
    # while ref? and prop = path.shift()
    try
      path.reduce ((a, b) -> a[b]), ref
    catch e
      return


  ###
  @method. property of the constructor.
  @signature: JsPath.getAt(ref, path)
  @param: obj - the object to extend.
  @param: path - a dot-notation style "path" to identify a
    nested JS object.
  @param: val - the value to assign to the path of the obj.
  @return: the object that was extended.
  @description: set a property to the path provided by the
    second parameter with the value provided by the third
    parameter.
  ###

  @setAt =(obj, path, val)->

    if 'function' is typeof path.split # ^1
      path = path.split '.'
    else
      path = path.slice()
    last = path.pop()
    prev = []
    ref = obj

    for component in path
      if primTypes.test typeof ref[component]
        throw new Error \
          """
          #{prev.concat(component).join '.'} is
          primitive, and cannot be extended.
          """
      ref = ref[component] or= {}
      prev.push component

    ref[last] = val
    obj


  @assureAt =(ref, path, initializer)->

    if obj = JsPath.getAt ref, path then obj
    else
      JsPath.setAt ref, path, initializer
      initializer


  ###
  @method. property of the constructor.
  @signature: JsPath.deleteAt(ref, path)
  @param: obj - the object to extend.
  @param: path - a dot-notation style "path" to identify a
    nested JS object to dereference.
  @return: boolean success.
  @description: deletes the reference specified by the last
    unit of the path from the object specified by other
    components of the path, belonging to the provided object.
  ###

  @deleteAt =(ref, path)->

    if 'function' is typeof path.split # ^1
      path = path.split '.'
    else
      path = path.slice()
    prev = []
    last = path.pop()

    for component in path
      if primTypes.test typeof ref[component]
        throw new Error \
          """
          #{prev.concat(component).join '.'} is
          primitive; cannot drill any deeper.
          """
      return no unless ref = ref[component]
      prev.push component

    delete ref[last]
