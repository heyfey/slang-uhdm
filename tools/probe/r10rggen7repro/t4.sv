// r10rggen7 t4: DEF-view ref_module port highConn for an interface-ARRAY port
// PASSED THROUGH from the enclosing module's own port.  Golden binds the
// highConn ref_obj's vpiActual to the enclosing module's OWN iface-port net
// (logic_net named after the port); a scalar iface port (bus_if here) binds
// the same way and already worked.  Rggen: rggen_apb_adapter:62
// .register_if(register_if).
interface t4_if;
  logic       valid;
  logic [7:0] addr;
  modport host (output valid, output addr);
  modport slave (input valid, input addr);
endinterface

module t4_child #(parameter int N = 2)(
  t4_if.slave scalar_if,
  t4_if.slave arr_if[N]
);
endmodule

module t4 #(parameter int N = 2)(
  t4_if.slave scalar_if,
  t4_if.slave arr_if[N]
);
  t4_child #(N) u_child (
    .scalar_if  (scalar_if),
    .arr_if     (arr_if)
  );
endmodule

module t4_top;
  t4_if s_if();
  t4_if a_if[2]();
  t4 #(2) u_t4 (.scalar_if(s_if), .arr_if(a_if));
endmodule
