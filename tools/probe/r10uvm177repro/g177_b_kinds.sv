// r10uvm177 grid arm B — DECLARED-TYPE KINDS under the PACKAGE listing.
// The arm A law says a PACKAGE-listing return typed through an ALIAS OF A
// TYPEDEF is a bare `ref_var`.  This arm asks the same question of EVERY other
// declared kind — struct, union, string, int, vector, real, class handle,
// unpacked array, and a bare (non-alias) typedef of each — so the law's SCOPE
// is measured and not assumed.  Names are unlike each other on purpose.
package bpk177;

  typedef enum { E1, E2 }              enum_direct;
  typedef enum_direct                  Enum_Via;      // alias of enum td

  typedef struct packed { bit [3:0] hi; bit [3:0] lo; } struct_direct;
  typedef struct_direct                STRUCT_VIA;    // alias of struct td

  typedef union packed { bit [7:0] u8; bit [7:0] v8; } union_direct;
  typedef union_direct                 unionVia;

  typedef int                          int_direct;
  typedef int_direct                   IntVia;

  typedef bit [11:0]                   vec_direct;
  typedef vec_direct                   VecVia;

  typedef string                       str_direct;
  typedef str_direct                   StrVia;

  typedef real                         real_direct;
  typedef real_direct                  RealVia;

  typedef byte                         byte_direct;
  typedef byte_direct                  ByteVia;

  class Handle177; int j; endclass
  typedef Handle177                    cls_direct;
  typedef cls_direct                   ClsVia;

  typedef int                          ua_base [3];
  typedef ua_base                      UaVia;

  function enum_direct   f_enum_d();   return E1; endfunction
  function Enum_Via      f_enum_v();   return E2; endfunction
  function struct_direct f_struct_d(); return '0; endfunction
  function STRUCT_VIA    f_struct_v(); return '0; endfunction
  function union_direct  f_union_d();  return '0; endfunction
  function unionVia      f_union_v();  return '0; endfunction
  function int_direct    f_int_d();    return 1;  endfunction
  function IntVia        f_int_v();    return 2;  endfunction
  function vec_direct    f_vec_d();    return 3;  endfunction
  function VecVia        f_vec_v();    return 4;  endfunction
  function str_direct    f_str_d();    return "a"; endfunction
  function StrVia        f_str_v();    return "b"; endfunction
  function real_direct   f_real_d();   return 1.0; endfunction
  function RealVia       f_real_v();   return 2.0; endfunction
  function byte_direct   f_byte_d();   return 8'd5; endfunction
  function ByteVia       f_byte_v();   return 8'd6; endfunction
  function cls_direct    f_cls_d();    return null; endfunction
  function ClsVia        f_cls_v();    return null; endfunction
  function ua_base       f_ua_d();     return '{default:0}; endfunction
  function UaVia         f_ua_v();     return '{default:0}; endfunction
endpackage

module bt177;
  import bpk177::*;
  initial $display(f_enum_d(), f_enum_v(), f_int_d(), f_int_v(),
                   f_str_d(), f_str_v(), f_vec_d(), f_vec_v());
endmodule
