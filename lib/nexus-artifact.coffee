
module.exports = (grunt) -> class NexusArtifact

  _ = grunt.util._

  # If an ID string is provided, this will return a config object suitable for creation of a NexusArtifact object
  @fromString = (idString) ->
    config = {}

    [config.group_id, config.name, config.ext, config.version] = idString.split(':')
    return config

  constructor: (config) ->
    {@url, @base_path, @repository, @group_id, @name, @version, @ext, @versionPattern} = config

  toString: () ->
    [@group_id, @name, @ext, @version].join(':')

  buildUrlPath: () ->
    _.compact(_.flatten([
      @url
      @base_path
      @repository
      @group_id.split('.')
      @name
      "#{@version}/"
    ])).join('/')

  buildUrl: () ->
    "#{@buildUrlPath()}#{@buildArtifactUri()}"

  buildArtifactUri: () ->
    grunt.log.writeln "@versionPattern #{@versionPattern}"
    expandedVersion = @expandVersion @version
    @versionPattern.replace /%([ave])/g, ($0, $1) =>
      { a: @name, v: expandedVersion, e: @ext}[$1]

  expandVersion: (version) ->
    if version.indexOf('-SNAPSHOT') > 0
      now = new Date()
      timestamp = '-' + now.toISOString().replace(/[-:]|\..*/g,'').replace('T','.')
      version = version.replace('-SNAPSHOT', timestamp)
    version