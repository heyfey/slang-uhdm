// v6: the SAME package class, with NO importer and NO instance anywhere
// (importers-absent axis; nothing elaborates the package into a module).
package vp6;
  parameter int PW = 4096;
  typedef logic signed [PW-1:0] bs_t;
  class C6;
    extern function bs_t oob();
    function bs_t inb(); inb = 'b0; endfunction
  endclass
  function bs_t C6::oob(); oob = 'b0; endfunction
  function bs_t free_ret(); free_ret = 'b0; endfunction
endpackage
