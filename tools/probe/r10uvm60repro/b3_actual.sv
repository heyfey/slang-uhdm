// b3_actual — AXIS 3: the ACTUAL's WRITTEN FORM on a `bit` formal, caller
// always a CLASS METHOD.  A1 bare `1`, A2 `1'b1`, A3 `64'd1`, A4 `4'd1`,
// A5 `'1`, A6 `1+1`, A7 a variable ref, A8 a localparam ref, A9 an enum member.
package p63;
   typedef enum bit {E0 = 1'b0, E1 = 1'b1} e63_t;
   localparam bit L63 = 1'b1;
   function void g63(bit b);
   endfunction

   class c63;
      bit v;
      function void call_all();
         g63(1);
         g63(1'b1);
         g63(64'd1);
         g63(4'd1);
         g63('1);
         g63(1 + 1);
         g63(v);
         g63(L63);
         g63(E1);
      endfunction
   endclass
endpackage
