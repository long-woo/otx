// 命令行参数类型定义
pub enum ArgType {
  String
  Int
  Bool
  Flag
}

// 参数定义结构
pub struct ArgDef {
  name : String
  short : String
  long : String
  arg_type : ArgType
  required : Bool
  default_value : String
  description : String
}

// 解析结果
pub struct ParsedArgs {
  args : Map[String, String]
  positional : Array[String]
  errors : Array[String]
}

// CLI解析器
pub struct CliParser {
  program_name : String
  description : String
  arg_defs : Array[ArgDef]
}

// 创建新的CLI解析器
pub fn new_parser(program_name : String, description : String) -> CliParser {
  {
    program_name,
    description,
    arg_defs: []
  }
}

// 添加参数定义
pub fn CliParser::add_arg(self : CliParser, name : String, short : String, long : String, 
                         arg_type : ArgType, required : Bool, default_value : String, 
                         description : String) -> CliParser {
  let arg_def = {
    name,
    short,
    long,
    arg_type,
    required,
    default_value,
    description
  }
  {
    program_name: self.program_name,
    description: self.description,
    arg_defs: self.arg_defs + [arg_def]
  }
}

// 添加字符串参数
pub fn CliParser::add_string_arg(self : CliParser, name : String, short : String, long : String,
                                required : Bool, default_value : String, description : String) -> CliParser {
  self.add_arg(name, short, long, String, required, default_value, description)
}

// 添加整数参数
pub fn CliParser::add_int_arg(self : CliParser, name : String, short : String, long : String,
                             required : Bool, default_value : String, description : String) -> CliParser {
  self.add_arg(name, short, long, Int, required, default_value, description)
}

// 添加布尔参数
pub fn CliParser::add_bool_arg(self : CliParser, name : String, short : String, long : String,
                              required : Bool, default_value : String, description : String) -> CliParser {
  self.add_arg(name, short, long, Bool, required, default_value, description)
}

// 添加标志参数（无值）
pub fn CliParser::add_flag(self : CliParser, name : String, short : String, long : String,
                          description : String) -> CliParser {
  self.add_arg(name, short, long, Flag, false, "false", description)
}

// 解析命令行参数
pub fn CliParser::parse(self : CliParser, args : Array[String]) -> ParsedArgs {
  let parsed_args : Map[String, String] = {}
  let mut positional : Array[String] = []
  let mut errors : Array[String] = []
  let mut i = 0
  
  // 初始化默认值
  for arg_def in self.arg_defs {
    if arg_def.default_value != "" {
      parsed_args[arg_def.name] = arg_def.default_value
    }
  }
  
  while i < args.length() {
    let arg = args[i]
    
    if arg.has_prefix("--") {
      // 长参数
      let arg_name = arg.substring(start=2)
      match self.find_arg_by_long(arg_name) {
        Some(arg_def) => {
          match arg_def.arg_type {
            Flag => parsed_args[arg_def.name] = "true"
            _ => {
              i = i + 1
              if i < args.length() {
                parsed_args[arg_def.name] = args[i]
              } else {
                errors = errors + ["参数 --" + arg_name + " 需要一个值"]
              }
            }
          }
        }
        None => errors = errors + ["未知参数: --" + arg_name]
      }
    } else if arg.has_prefix("-") && arg.length() > 1 {
      // 短参数
      let arg_name = arg.substring(start=1)
      match self.find_arg_by_short(arg_name) {
        Some(arg_def) => {
          match arg_def.arg_type {
            Flag => parsed_args[arg_def.name] = "true"
            _ => {
              i = i + 1
              if i < args.length() {
                parsed_args[arg_def.name] = args[i]
              } else {
                errors = errors + ["参数 -" + arg_name + " 需要一个值"]
              }
            }
          }
        }
        None => errors = errors + ["未知参数: -" + arg_name]
      }
    } else {
      // 位置参数
      positional = positional + [arg]
    }
    
    i = i + 1
  }
  
  // 检查必需参数
  for arg_def in self.arg_defs {
    if arg_def.required && not(parsed_args.contains(arg_def.name)) {
      errors = errors + ["缺少必需参数: " + arg_def.name]
    }
  }
  
  { args: parsed_args, positional, errors }
}

// 根据长参数名查找参数定义
fn CliParser::find_arg_by_long(self : CliParser, long : String) -> Option[ArgDef] {
  for arg_def in self.arg_defs {
    if arg_def.long == long {
      return Some(arg_def)
    }
  }
  None
}

// 根据短参数名查找参数定义
fn CliParser::find_arg_by_short(self : CliParser, short : String) -> Option[ArgDef] {
  for arg_def in self.arg_defs {
    if arg_def.short == short {
      return Some(arg_def)
    }
  }
  None
}

// 生成帮助信息
pub fn CliParser::help(self : CliParser) -> String {
  let mut help_text = "用法: " + self.program_name + " [选项]\n\n"
  help_text = help_text + self.description + "\n\n选项:\n"
  
  for arg_def in self.arg_defs {
    let short_part = if arg_def.short != "" { "-" + arg_def.short + ", " } else { "    " }
    let long_part = "--" + arg_def.long
    let required_part = if arg_def.required { " (必需)" } else { "" }
    let default_part = if arg_def.default_value != "" && arg_def.default_value != "false" { 
      " [默认: " + arg_def.default_value + "]"
    } else { "" }
    
    help_text = help_text + "  " + short_part + long_part + "\n"
    help_text = help_text + "        " + arg_def.description + required_part + default_part + "\n\n"
  }
  
  help_text
}

// 获取解析后的字符串值
pub fn ParsedArgs::get_string(self : ParsedArgs, name : String) -> Option[String] {
  self.args.get(name)
}

// 获取解析后的整数值
pub fn ParsedArgs::get_int(self : ParsedArgs, name : String) -> Option[Int] {
  match self.args.get(name) {
    Some(value) => {
      try {
         Some(@strconv.parse_int(value))
       } catch {
         _ => None
       }
    }
    None => None
  }
}

// 获取解析后的布尔值
pub fn ParsedArgs::get_bool(self : ParsedArgs, name : String) -> Bool {
  match self.args.get(name) {
    Some(value) => value == "true"
    None => false
  }
}

// 检查是否有错误
pub fn ParsedArgs::has_errors(self : ParsedArgs) -> Bool {
  self.errors.length() > 0
}

// 获取错误信息
pub fn ParsedArgs::get_errors(self : ParsedArgs) -> String {
  self.errors.join("\n")
}