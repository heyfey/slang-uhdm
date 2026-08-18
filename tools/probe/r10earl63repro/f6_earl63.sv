// r10earl63 — F6: does an ELEMENT SELECT over an UNPACKED array in a const
// function's return assignment produce the BIN (select) producer?
// The ArrayExprFuncArg shape, isolated.  MEASUREMENT ONLY.
module s6;
  localparam int CNT = 3;
  localparam int unsigned ARR [CNT] = '{1, 5, 3};
  function static int unsigned f_amax(int unsigned SRC[CNT], int unsigned ICNT);
    f_amax = 0;
    for (int i = 0; i < ICNT; i++) begin
      if (SRC[i] > f_amax) begin
        f_amax = SRC[i];
      end
    end
  endfunction
  function static int unsigned f_aret(int unsigned SRC[CNT]);
    return SRC[1];
  endfunction
  function static int unsigned f_aasg(int unsigned SRC[CNT]);
    f_aasg = SRC[1];
  endfunction
  function static int unsigned f_alit(int unsigned SRC[CNT]);
    f_alit = 7;
  endfunction
  localparam int unsigned t_amax = f_amax(ARR, CNT);
  localparam int          i_amax = f_amax(ARR, CNT);
  localparam byte         b_amax = f_amax(ARR, CNT);
  localparam              u_amax = f_amax(ARR, CNT);
  localparam int unsigned t_aret = f_aret(ARR);
  localparam int unsigned t_aasg = f_aasg(ARR);
  localparam              u_aret = f_aret(ARR);
  localparam              u_aasg = f_aasg(ARR);
  localparam int unsigned t_alit = f_alit(ARR);
endmodule
