import PySimpleGUI as sg

layout = [[sg.Text("UserName: "), sg.Text("Username123456")], [sg.Text("Credit Balance: "), sg.Text("9,999,999")], [sg.Button("OK")], [sg.Image(key="C:/Users/treyh/PycharmProjects/DCSGUI1/51L0-hXjy+L.png")]]
imageview = [sg.Image(key="C:/Users/treyh/PycharmProjects/DCSGUI1/51L0-hXjy+L.png")]
# Create the window
window = sg.Window("DGSC Manager", layout)

# Create an event loop
while True:
    event, values = window.read()
    # End program if user closes window or
    # presses the OK button
    if event == "OK" or event == sg.WIN_CLOSED:
        break

window.close()
