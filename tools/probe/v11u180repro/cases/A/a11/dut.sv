// § classTpDefaultTsAtUse180 (verifier: two type parameters, each with a formal and a use, interleaved)
package pkg;
  class req_c; endclass
  class rsp_c; endclass
  class holder #(type REQ=req_c, type RSP=rsp_c);
    RSP r0;
    REQ q0;
    function void put(REQ q, RSP r); q0 = q; r0 = r; endfunction
    function RSP get(); return r0; endfunction
    task t(output REQ q); q = q0; endtask
  endclass
endpackage
module top();
pkg::holder c1;
endmodule
