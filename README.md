# DigitalLogicDesign

Goal of the project is to implement a logic component capable of computing the Working Zone" encoding.
This method is used by the address bus which encondes an address before of transmitting it.
A working zone is defined as an interval of addresses of fixed dimension (Dwz), starting from a base address.
Obviously, in the same schema there could be several working zones.

The schema is as follows:<br>
  ● if the address does not belong to any working zone, it's transmitted without being encoded, and an optional bit (WZ_BIT) is added with value 0;
  The transmitted address would be (WZ_BIT & ADDR, where  & represent the concatenation between the strings of bit);<br>
  ● if the address does belong to a working zone, the WZ_BIT is set to 1, whereas the remaining bits of the string are divided in two parts:
    <br>- the number of the working zone to which the address belongs WZ_NUM (binary enconded);
    <br>- the offset from the base address of the working zone WZ_OFFSET (One_hot encoded);
    Therefore, the transmitted address would be WZ_BIT(=1) & WZ_NUM & WZ_OFFSET.

In the implemented version of the working_zone method, the address to be encoded has a fixed lenght of 7 bits, thus the valid addresses span from 0 to 127.
Number of the working_zones = 8, and the dimension of each working_zone is equale to 4, base address included.
Therefore, the encoded address would be 8 bits long:
    - 1 bit for WZ_BIT + 7 bits for ADDR (in case of the address does not belong to any WZ);
    - 1 bit per WZ_BIT + 3 bits for the binary WZ encoding + 4 bits for the one hot WZ_OFFSET encoding (in case of the address belongs to a WZ).

For further information on how working_zone method works:
E. Musoll, T. Lang and J. Cortadella, "Working-zone encoding for reducing the energy in microprocessor address buses", in IEEE
Transactions on Very Large Scale Integration (VLSI) Systems , vol. 6, no. 4, pp. 568-572, Dec. 1998
