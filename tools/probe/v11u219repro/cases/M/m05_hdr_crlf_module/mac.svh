`define SHOW(ID,MSG) \
   begin \
     $display("%s %s", ID, MSG); \
   end
`define TRM(CB,METHOD) \
  begin \
    `SHOW("T", $sformatf("%s", \
       CB.get_name())) \
    CB.METHOD; \
  end
