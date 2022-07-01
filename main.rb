require 'ferrum'
require 'cgi'

class Main
  CITA_URL = ENV['CITA_URL']

  API_TOKEN = ENV['API_TOKEN']
  CHAT_ID   = ENV['CHAT_ID']
  API_URL   = "https://api.telegram.org/bot#{API_TOKEN}"

  TIMETABLE = [
    [0, 10],
    [40, 50]
  ].freeze

  def call
    return puts 'Script execution skipped' unless in_timetable?

    setup_browser!
    check!
  rescue StandardError => e
    send_message("Something went wrong on script execution 👎\n\nDetails:\n\n#{e.message}")

    false
  end

  private

  def in_timetable?
    current_minute = Time.now.min

    TIMETABLE.any? { |pair| current_minute >= pair[0] && current_minute < pair[1] }
  end

  def setup_browser!
    @browser  = Ferrum::Browser.new(headless: true)

    at_exit { @browser.quit if @browser.process }
  end

  def check!
    @browser.go_to(CITA_URL)

    puts '### Selecting province ###'
    alicante = '/icpco/citar?p=3&locale=es'
    @browser.execute(
      %[
        document.querySelector('#form').value = "#{alicante}"
      ]
    )
    sleep 3

    puts '--- Selected province ---'
    @browser.at_css('#btnAceptar').click
    sleep 3

    puts '### Selecting cita reason ###'
    tie = '4112'
    @browser.execute(
      %[
        let select = document.querySelector('select[name="tramiteGrupo[1]"]')
        select.scrollIntoView()
        select.value = "#{tie}"
      ]
    )
    sleep 3

    puts '--- Selected cita reason ---'
    @browser.at_css('#btnAceptar').click
    sleep 3

    puts '--- Accepting terms & conditions ---'
    @browser.execute(
      %[
        let element = document.querySelector('#btnEntrar')
        element.scrollIntoView()
        element.click()
      ]
    )
    sleep 3

    puts '### Entering NIE ###'
    nie = %w[Y0413118Y Y1317009C Y9312258D Y1364985H Y6558711E].sample
    full_name = [
      'TYMOFIJ RYBAK', 'YEHOR KOROL', 'NAZAR SAVCHENKO',
      'STANISLAVA VELYCHKO', 'ANTONINA SLOBODYAN', 'IRYNA LUKYANENKO'
    ].sample
    @browser.execute(
      %[
        document.querySelector('#txtIdCitado').value = "#{nie}"
        document.querySelector('#txtDesCitado').value = "#{full_name}"
      ]
    )
    sleep 3

    puts '--- Entered NIE ---'
    @browser.at_css('#btnEnviar').click
    sleep 3

    puts '--- Submitting cita ---'
    @browser.at_css('#btnEnviar').click
    sleep 3

    read_final_page
  end

  def read_final_page
    puts '--- Printing info about cita ---'

    text = @browser.at_css('form[name="procedimientos"] > div').text
    puts text

    return send_message('There are no citas at the moment 😔') if text.match?(/no hay citas disponibles/)

    options = @browser.css('#idSede option')
    options = [OpenStruct.new(text: 'Options could not be parsed.')] if options.empty?
    options = options.select { |option| !option.text&.match?(/Seleccionar/) }
                     .map { |option| "- #{option.text}" }.join("\n\n")

    send_message(
      "Probably there is a cita available 🤟\n" \
      "Check it here: #{CITA_URL}.\n\n" \
      "Possible options:\n\n" \
      "#{options}"
    )
  end

  def send_message(message)
    puts message

    %x(
      curl -X GET -G '#{API_URL}/sendMessage' \
        -d chat_id=#{CHAT_ID} \
        -d parse_mode=Markdown \
        -d text=#{CGI.escape(message)}
    )
  end
end

Main.new.call
