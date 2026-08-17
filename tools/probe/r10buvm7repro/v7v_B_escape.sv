// vbuvm7 adversarial arm B — ESCAPED IDENTIFIERS (earl53's lesson).
typedef struct { int used; int \esc.mem ; } stB_t;
module topB;
  stB_t \arr[0] [4];      // escaped name CONTAINING brackets
  stB_t \my.name [4];     // escaped name CONTAINING a dot
  stB_t \plain [4];       // ordinary escaped name
  stB_t barr[4];
  initial begin
    barr[1].used++;            // B0 control
    \plain [1].used++;         // B1 escaped base
    \arr[0] [1].used++;        // B2 escaped base whose NAME has brackets
    \my.name [1].used++;       // B3 escaped base whose NAME has a dot
    \plain [2].\esc.mem ++;    // B4 escaped MEMBER name with a dot
  end
endmodule
