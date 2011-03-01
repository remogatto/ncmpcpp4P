def check_ldd(binary_fn)
  FileUtils.mkdir(PND_LIB_PATH) unless File.exists?(PND_LIB_PATH)
  ldd_output = `ldd #{binary_fn}`.split("\n")
  ldd_output.each do |line|
    line.strip!
    splits = line.split('=>')
    unless splits[1].nil?
      path = splits[1].gsub(/\(0x(.*)/, '').strip
      NAND_PATHS.each_with_index do |nand_path, i|
        nand_fn = File.join(nand_path, File.basename(path)).strip
        if File.exists?(nand_fn)
          break
        else
          FileUtils.cp_r(path, PND_LIB_PATH, :verbose => true) unless File.exists?(nand_fn) if i == 1
        end
      end
    end
  end
end

def pnd_version(fn)
  pxml = File.read(fn)
  pxml.scan(/major="(\d)" minor="(\d)" release="(\d)" build="(\d)"/).flatten
end
