// r10uvm166 GRID B -- THE ELEMENT AXIS.  MEASUREMENT ONLY.
// WHICH unpacked-array typedef loses its typespec in Surelog, i.e. which one
// makes the declaration a bare `ref_var` instead of an `array_var`.
package qb166;

  class Sled166;
    int mark166;
  endclass

  typedef enum { LOW166, HIGH166 } tone166_e;
  typedef struct packed { bit [3:0] hi166; bit [3:0] lo166; } duo166_s;

  // A generic class whose type parameter is bound, by default, to each of the
  // kinds a target can have.  Names are deliberately unlike each other.
  class Hopper166 #(type WIRE166 = int,
                    type CARGO166 = Sled166,
                    type FLAG166 = tone166_e,
                    type SLAB166 = duo166_s,
                    type WORD166 = string,
                    parameter int DEPTH166 = 3);
    typedef WIRE166  wireQ166_t[$];
    typedef CARGO166 cargoQ166_t[$];
    typedef FLAG166  flagQ166_t[$];
    typedef SLAB166  slabQ166_t[$];
    typedef WORD166  wordQ166_t[$];
    typedef WIRE166  chain166_t;
    typedef chain166_t chainQ166_t[$];      // array of a TYPEDEF OF a type param
    typedef WIRE166  deepQ166_t[$][$];      // array of array of a type param
    typedef int      keyed166_t[WIRE166];   // ASSOC whose INDEX is a type param
    typedef int      sized166_t[DEPTH166];  // fixed dim from a VALUE parameter
    typedef Sled166  fixedQ166_t[$];        // concrete class element
    typedef tone166_e toneQ166_t[$];
    typedef duo166_s  duoQ166_t[$];
    typedef string    textQ166_t[$];
    typedef real      realQ166_t[$];

    static function void haul166();
      wireQ166_t  wireVal166;
      cargoQ166_t cargoVal166;
      flagQ166_t  flagVal166;
      slabQ166_t  slabVal166;
      wordQ166_t  wordVal166;
      chainQ166_t chainVal166;
      deepQ166_t  deepVal166;
      keyed166_t  keyedVal166;
      sized166_t  sizedVal166;
      fixedQ166_t fixedVal166;
      toneQ166_t  toneVal166;
      duoQ166_t   duoVal166;
      textQ166_t  textVal166;
      realQ166_t  realVal166;
    endfunction
  endclass

endpackage

module rig166;
  parameter type BOLT166 = int;
  typedef BOLT166 boltQ166_t[$];
  typedef int     nutQ166_t[$];
  function automatic void tighten166();
    boltQ166_t boltVal166;
    nutQ166_t  nutVal166;
  endfunction
  initial tighten166();
endmodule
