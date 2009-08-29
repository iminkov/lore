
require 'rake'

spec = Gem::Specification.new { |s|

  s.name = 'lore' 
  s.rubyforge_project = 'lore'
  s.summary = 'A flexible ORM based on PostgreSQL'
  s.description = <<-EOF
    Lore is an object-relational mapping (ORM) implementation 
    providing many features like prepared statements, 
    (multiple) inheritance, true polymorphism, a comfortable 
    query syntax, highly customizable automated form generation, 
    and result caching. 
    It aims at performance, usability and - unlike most ORMs - 
    high coverage of object oriented paradigms. 
    Lore is currently using PostgreSQL as database backend. 
  EOF
  s.version = '0.9.2'
  s.author  = 'Tobias Fuchs'
  s.email   = 'twh.fuchs@gmail.com'
  s.date    = Time.now
  s.files   = '*.rb'

  s.requirements  = "A ruby binding for PostgreSQL, such as postgres or postgres-pr. "
# Remove dependency as postgres-pr would be ok, too
# s.add_dependency('postgres', '>= 0.1')
  s.add_dependency('aurita-gui', '>= 0.2')
  s.files = [
     './benchmark',
     './benchmark/select.rb',
     './benchmark/benchmark.sql',
     './benchmark/results.txt',
     './TODO.txt',
     './Manifest.txt',
     './spec',
     './spec/model_union_select.rb',
     './spec/model_associations.rb',
     './spec/run',
     './spec/fixtures',
     './spec/fixtures/models.rb',
     './spec/fixtures/blank_models.rb',
     './spec/fixtures/polymorphic_models.rb',
     './spec/model_delete.rb',
     './spec/clause.rb',
     './spec/model_select_eager.rb',
     './spec/model_definition.rb',
     './spec/spec_helpers.rb',
     './spec/model_select.rb',
     './spec/model_create.rb',
     './spec/model_polymorphic.rb',
     './spec/spec_db.sql',
     './spec/model_inheritance.rb',
     './spec/model_validation.rb',
     './spec/spec.log',
     './spec/model_update.rb',
     './spec/spec_env.rb',
     './lib',
     './lib/lore.rb',
     './lib/lore',
     './lib/lore/strategies',
     './lib/lore/strategies/table_select.rb',
     './lib/lore/strategies/.table_insert.rb.swp',
     './lib/lore/strategies/table_delete.rb',
     './lib/lore/strategies/table_update.rb',
     './lib/lore/strategies/table_insert.rb',
     './lib/lore/migration.rb',
     './lib/lore/exceptions',
     './lib/lore/exceptions/unknown_type.rb',
     './lib/lore/exceptions/invalid_field.rb',
     './lib/lore/exceptions/validation_failure.rb',
     './lib/lore/exceptions/cache_exception.rb',
     './lib/lore/exceptions/database_exception.rb',
     './lib/lore/exceptions/ambiguous_attribute.rb',
     './lib/lore/model',
     './lib/lore/model/mockable.rb',
     './lib/lore/model/filters.rb',
     './lib/lore/model/attribute_settings.rb',
     './lib/lore/model/model_instance.rb',
     './lib/lore/model/model_shortcuts.rb',
     './lib/lore/model/polymorphic.rb',
     './lib/lore/model/model_factory.rb',
     './lib/lore/model/aspect.rb',
     './lib/lore/model/prepare.rb',
     './lib/lore/model/table_accessor.rb',
     './lib/lore/model/behaviours',
     './lib/lore/model/behaviours/lockable.rb',
     './lib/lore/model/behaviours/versioned.rb',
     './lib/lore/model/behaviours/taggable.rb',
     './lib/lore/model/behaviours/paginated.rb',
     './lib/lore/model/behaviours/movable.rb',
     './lib/lore/model/associations.rb',
     './lib/lore/validation',
     './lib/lore/validation/parameter_validator.rb',
     './lib/lore/validation/type_validator.rb',
     './lib/lore/clause.rb',
     './lib/lore/gui',
     './lib/lore/gui/form_generator.rb',
     './lib/lore/gui/lore_model_select_field.rb',
     './lib/lore/query_shortcuts.rb',
     './lib/lore/cache',
     './lib/lore/cache/mmap_entity_cache.rb',
     './lib/lore/cache/file_index.rb',
     './lib/lore/cache/memory_entity_cache.rb',
     './lib/lore/cache/abstract_entity_cache.rb',
     './lib/lore/cache/bits.rb',
     './lib/lore/cache/mmap_entity_cache_bork.rb',
     './lib/lore/cache/cached_entities.rb',
     './lib/lore/cache/memcache_entity_cache.rb',
     './lib/lore/cache/cacheable.rb',
     './lib/lore/bits.rb',
     './lib/lore/model.rb',
     './lib/lore/query.rb',
     './lib/lore/adapters',
     './lib/lore/adapters/context.rb',
     './lib/lore/adapters/postgres-pr.rb',
     './lib/lore/adapters/postgres',
     './lib/lore/adapters/postgres/connection.rb',
     './lib/lore/adapters/postgres/types.rb',
     './lib/lore/adapters/postgres/result.rb',
     './lib/lore/adapters/postgres.rb',
     './lib/lore/adapters/postgres-pr',
     './lib/lore/adapters/postgres-pr/connection.rb',
     './lib/lore/adapters/postgres-pr/types.rb',
     './lib/lore/adapters/postgres-pr/result.rb',
     './bin',
     './bin/setup_db.rb',
     './bin/custom_functions.sql',
     './LICENSE'
  ]
  s.has_rdoc = true
  s.rdoc_options << '--title' << 'Lore ORM' <<
                    '--main' << 'Lore::Model' <<
                    '--line-numbers'

  s.homepage = 'http://github.com/fuchsto/lore/'

}
