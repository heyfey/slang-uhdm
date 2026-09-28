// § pkgImpParamAliasColons210 — vp03 (v11u210 break probe): a package that wildcard-imports AND re-exports another package's vector-typedef parameters, read through the export in a function by a module that imports only the exporter
package ap;
  typedef logic [2:0] m_t;
  parameter m_t M0 = 3'd1;
  parameter m_t M1 = 3'd6;
endpackage
package bp;
  import ap::*;
  export ap::*;
  function automatic logic [2:0] pick(logic s);
    return s ? M1 : M0;
  endfunction
endpackage
module dut import bp::*; (input logic s, output logic [2:0] o);
  assign o = pick(s);
endmodule
