0. 1. context

      - Nodelib context-module

        - contructor should accept

          1. a seed object
          2. a seed object and (super)context property object

        - instances

          - can handle path-references

            - which dereference

              1. to objects
              2. to values--even if empty
              3. to objects with unresolved references

            - which resolve

              1. to fully dereferenced objects
              2. to values
              3. to referenced values
              4. to values on referenced objects
              5. to objects merged with reference objects
              6. to objects merged with reference objects (II)
              7. to fully dereferenced objects


          1. should create and track subContexts, and override properties
          2. should inherit property values, but not export values to the super context

        1. exports a class called Context
        2. should numerically Id its instances

   2. module

      - Module 'nodelib.module' provides classes and routines to set up an Express application.

        - To do so it has a framework composed of two extensible components.

          - First, the core,

            - that can statically configure itself,

              1. taking paths to the source
              2. optionally using config modules
              3. by loading the metadatafile in the current directory.

            - Core instances have

              1. a method to load modules onto the core instance
              2. and a method to prime and run the application server.

            1. which is a prototype for an object

          - Second is the module

            - that can statically configure itself, taking a path to a directory

              1. either containing a standard module layout
              2. or which has a reserved-name module metadata file.

            1. which is a prototype


        - To start an express-mvc 0.1 application

          1. it requires a global init. FIXME: fix this somehow.
          2. it requires to load a core component from a module
          3. it requires a call to configure the core component
          4. it can load extensions.
          5. it finally has a function to start the Express app.

   4. route

      - Module 'route'

        - works with metadata objects containing a 'route' attribute

          - that may hold any of the HTTP verbs

            1. with a resolvable named handler
            2. with a dynamic reference to a callable handler

          1. the value of which is an object
          2. which may hold the same key to a sub-route

        - applies URL route handlers to an Express instance from static or dynamic metadata.

          1. XXX take an express, urlBase, mock arg, and return an merged route
          2. It can recursively traverse the 'route' key from an object
          3. It can take names of handlers for singleton controllers
          4. It can take dynamic references to handlers

        1. has one principal function applyRoutes

   5. specs
   6. table
   7. util
   8. metadata
   9. mocha-specs
