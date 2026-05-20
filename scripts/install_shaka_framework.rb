require 'fileutils'
require 'net/http'
require 'tmpdir'
require 'uri'

module RNShakaPlayer
  module FrameworkInstaller
    SHAKA_VERSION = 'v1.0.0'
    SHAKA_URL = "https://github.com/shaka-project/shaka-player-embedded/releases/download/#{SHAKA_VERSION}/ShakaPlayerEmbedded_arm64.framework.tar.bz2"
    ARCHIVE_NAME = 'ShakaPlayerEmbedded_arm64.framework.tar.bz2'

    module_function

    def install(root_dir)
      apple_dir = File.join(root_dir, 'apple')
      archive_path = File.join(apple_dir, ARCHIVE_NAME)
      xcframework = File.join(apple_dir, 'ShakaPlayerEmbedded.xcframework')
      ffmpeg_xcframework = File.join(apple_dir, 'ShakaPlayerEmbedded.FFmpeg.xcframework')

      return if File.directory?(xcframework) && File.directory?(ffmpeg_xcframework)

      FileUtils.mkdir_p(apple_dir)

      unless File.exist?(archive_path)
        puts "[RNShakaPlayer] Downloading ShakaPlayerEmbedded framework from #{SHAKA_URL}"
        download(SHAKA_URL, archive_path)
      end

      # The framework bundles contain symlinks (Versions/A/...), so extracting
      # and building directly under apple/ fails on filesystems that don't
      # support symlinks (e.g. ExFAT). Do all the work in a system tmpdir
      # (APFS) and copy the results back with symlinks dereferenced.
      Dir.mktmpdir('rnshakaplayer-') do |work_dir|
        puts "[RNShakaPlayer] Extracting #{ARCHIVE_NAME} into #{work_dir}"
        run!(%(tar xjf "#{archive_path}" -C "#{work_dir}"))

        framework = File.join(work_dir, 'ShakaPlayerEmbedded.framework')
        ffmpeg_framework = File.join(work_dir, 'ShakaPlayerEmbedded.FFmpeg.framework')

        unless File.directory?(framework) && File.directory?(ffmpeg_framework)
          raise "[RNShakaPlayer] Archive did not contain the expected .framework bundles"
        end

        tmp_xcframework = File.join(work_dir, 'ShakaPlayerEmbedded.xcframework')
        tmp_ffmpeg_xcframework = File.join(work_dir, 'ShakaPlayerEmbedded.FFmpeg.xcframework')

        puts "[RNShakaPlayer] Creating ShakaPlayerEmbedded.xcframework"
        run!(%(xcodebuild -create-xcframework -framework "#{framework}" -output "#{tmp_xcframework}"))

        puts "[RNShakaPlayer] Creating ShakaPlayerEmbedded.FFmpeg.xcframework"
        run!(%(xcodebuild -create-xcframework -framework "#{ffmpeg_framework}" -output "#{tmp_ffmpeg_xcframework}"))

        copy_dereferencing(tmp_xcframework, xcframework)
        copy_dereferencing(tmp_ffmpeg_xcframework, ffmpeg_xcframework)
      end
    end

    # rsync --copy-links replaces symlinks with copies of their targets,
    # so the destination tree has no symlinks (required on ExFAT/FAT32).
    def copy_dereferencing(src, dest)
      FileUtils.rm_rf(dest)
      run!(%(rsync -a --copy-links "#{src}/" "#{dest}/"))
    end

    def download(url, dest, redirect_limit = 5)
      raise "Too many HTTP redirects while downloading #{url}" if redirect_limit <= 0

      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request) do |response|
          case response
          when Net::HTTPSuccess
            File.open(dest, 'wb') do |file|
              response.read_body { |chunk| file.write(chunk) }
            end
          when Net::HTTPRedirection
            download(response['location'], dest, redirect_limit - 1)
          else
            raise "Failed to download #{url}: #{response.code} #{response.message}"
          end
        end
      end
    end

    def run!(command)
      unless system(command)
        raise "[RNShakaPlayer] Command failed: #{command}"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  RNShakaPlayer::FrameworkInstaller.install(File.expand_path('..', __dir__))
end
