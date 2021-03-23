# Author: Quentin Ducasse
#   mail:   quentin.ducasse@ensta-bretagne.org
#   github: QDucasse
# =================================
# Templating utility to generate the top module with two filled memories from the
# binary file

from jinja2 import Environment, FileSystemLoader

class TemplateHandler():

    TEMPLATE_CFG = "auto_config_memory.vhd.template"
    TEMPLATE_PRG = "auto_program_memory.vhd.template"

    def __init__(self, cfg_mem_file_name, out_cfg_mem_file, cfg_mem_size,
                       prg_mem_file_name, out_prg_mem_file, prg_mem_size):

        self.environment = Environment(loader=FileSystemLoader('templates'))
        self.template_cfg_mem = self.environment.get_template(self.TEMPLATE_CFG)
        self.template_prg_mem = self.environment.get_template(self.TEMPLATE_PRG)
        # Read program instructions
        self.instructions = []
        with open(prg_mem_file_name, "rb") as file:
            instruction = file.read(4)  # read(1) processes 1 byte, we need 4 for an instruction
            while instruction:
                self.instructions.append(int.from_bytes(instruction, "little"))
                instruction = file.read(4)
        self.instructions = ["{0:0{1}X}".format(instruction, 8) for instruction in self.instructions]
        self.fill_instructions(prg_mem_size)
        # Read config
        # IF BINARY CONFIG
        # with open(cfg_mem_file_name, "rb") as file:
        #   self.config = int.from_bytes(file.read(), "big")
        with open(cfg_mem_file_name, "r") as file:
            self.config = file.read().strip()
        self.config = self.config.zfill(cfg_mem_size)

        self.out_cfg_mem_file = out_cfg_mem_file
        self.out_prg_mem_file = out_prg_mem_file

    def fill_instructions(self, size):
        while len(self.instructions) < size:
            self.instructions.append("00000000")

    def render_config_memory(self):
        return self.template_cfg_mem.render(
            config=self.config
        )

    def render_program_memory(self):
        return self.template_prg_mem.render(
            instructions=self.instructions
        )

    def write_output_config_memory(self):
        with open(self.out_cfg_mem_file, "w") as file:
            file.write(self.render_config_memory())

    def write_output_program_memory(self):
        with open(self.out_prg_mem_file, "w") as file:
            file.write(self.render_program_memory())

    def gen_memories(self):
        self.write_output_config_memory()
        self.write_output_program_memory()

if __name__ == "__main__":
    th = TemplateHandler(
        "templates/adding.6.cfg", "src/auto_config_memory.vhd",  128,
        "templates/adding.6.out", "src/auto_program_memory.vhd", 256
    )
    th.gen_memories()
