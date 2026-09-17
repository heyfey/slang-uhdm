// v2 - ALIAS CHAINS.  The landed aliasOfAlias0 guard (ModuleEmit def net loop)
// zeroes a net whose alias target is a PACKED ARRAY OF AN ALIAS -- but that
// guard reads dt->getType().kind == TypeAlias, which an unpacked dim defeats.
package pk2;
  typedef logic [1:0] pv_t;
  typedef pv_t [1:0] pw_t;
endpackage
module dut (output logic [3:0] o);
  import pk2::pv_t;
  import pk2::pw_t;
  typedef logic [1:0] v_t;
  typedef v_t [1:0] w_t;     // alias-of-alias: PackedArray OF an alias
  typedef v_t   v2_t;        // plain alias-of-alias
  typedef w_t   wa_t [2];    // unpacked typedef whose ELEMENT is alias-of-alias
  typedef v2_t  c_t  [2];    // unpacked typedef whose ELEMENT is a plain alias

  w_t  wnod;                 // control: alias-of-alias, NO dim
  w_t  wdim [2];             // alias-of-alias + DECLARATOR dim
  v2_t chain [2];            // plain alias-of-alias + declarator dim
  wa_t warr;                 // unpacked typedef over alias-of-alias
  c_t  carr;
  pw_t pwd [2];              // imported alias-of-alias + declarator dim
  v_t [1:0] sel [2];         // IdentifierSelectName (packed dim on the name)

  assign o = {2'b0, wnod[0] | wdim[0][0] | chain[0] | warr[0][0] | carr[0] |
                    pwd[0][0] | sel[0][0]};
endmodule
