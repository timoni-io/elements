package main

import (
	"fmt"
	"net/smtp"
	"os"

	"github.com/BurntSushi/toml"
	"github.com/google/uuid"
)

type SmtpHost struct {
	Id   string `toml:"id"`
	Name string `toml:"name"`
	Port int64  `toml:"port"`
}

type SmtpTestAccount struct {
	FromUser  string `toml:"from_user"`
	ToUser    string `toml:"to_user"`
	SmtpLogin string `toml:"smtp_login"`
	SmtpPass  string `toml:"smtp_pass"`
}

func loadFile(fileName string) []byte {
	fileData, err := os.ReadFile(fileName)
	if err != nil {
		panic(
			fmt.Sprintf(
				"Problem with reading '%v' file: %v",
				fileName,
				err,
			),
		)
	}
	return fileData
}

func main() {
	smtpHostRawData := loadFile("server.toml")
	var smtpHost SmtpHost
	errUmh := toml.Unmarshal(smtpHostRawData, &smtpHost)
	if errUmh != nil {
		panic(
			fmt.Sprintf(
				"Prroblem with decoding 'server.toml' TOML data: %v",
				errUmh,
			),
		)
	}

	fmt.Println("SMTP id:", smtpHost.Id)
	fmt.Println("SMTP host:", smtpHost.Name)
	fmt.Println("SMTP port:", smtpHost.Port)
	smtpEndpoint := fmt.Sprintf(
		"%v:%v",
		smtpHost.Name,
		smtpHost.Port,
	)
	fmt.Println("SMTP endpoint:", smtpEndpoint)

	testUserData := loadFile("test_input.toml")
	var testUser SmtpTestAccount
	errUmu := toml.Unmarshal(testUserData, &testUser)
	fmt.Println(errUmu)
	if errUmu != nil {
		panic(
			fmt.Sprintf(
				"Prroblem with decoding 'test_input.toml' TOML data: %v",
				errUmu,
			),
		)
	}

	fmt.Println("From", testUser.FromUser)
	fmt.Println("To", testUser.ToUser)
	fmt.Println("Login", testUser.SmtpLogin)
	fmt.Println("Pass", testUser.SmtpPass)

	message, errReadMessage := os.ReadFile("message.txt")
	if errReadMessage != nil {
		panic("Can't read message.txt file")
	}
	messageId := []byte(uuid.New().String())
	message = append(message, messageId...)
	smtpFromUser := testUser.FromUser
	smtpToUser := testUser.ToUser
	// authorization := smtp.CRAMMD5Auth(testUser.SmtpLogin, testUser.SmtpPass)
	err := smtp.SendMail(
		smtpEndpoint,
		nil,
		smtpFromUser,
		[]string{smtpToUser},
		message,
	)
	if err != nil {
		panic(err)
	}
}
