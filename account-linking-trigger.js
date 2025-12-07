const { CognitoIdentityProviderClient, AdminLinkProviderForUserCommand, AdminGetUserCommand } = require('@aws-sdk/client-cognito-identity-provider');

const cognitoClient = new CognitoIdentityProviderClient({ region: process.env.AWS_REGION });

exports.handler = async (event) => {
    console.log('Pre-signup trigger event:', JSON.stringify(event, null, 2));
    
    try {
        const { userPoolId, triggerSource, request } = event;
        const { userAttributes } = request;
        const email = userAttributes.email;
        
        // Only handle external provider signups
        if (triggerSource === 'PreSignUp_ExternalProvider') {
            console.log('External provider signup detected for email:', email);
            
            try {
                // Check if user already exists with this email
                const existingUser = await cognitoClient.send(new AdminGetUserCommand({
                    UserPoolId: userPoolId,
                    Username: email
                }));
                
                console.log('Found existing user:', existingUser.Username);
                
                // Link the external provider to existing user
                await cognitoClient.send(new AdminLinkProviderForUserCommand({
                    UserPoolId: userPoolId,
                    DestinationUser: {
                        ProviderName: 'Cognito',
                        ProviderAttributeValue: existingUser.Username
                    },
                    SourceUser: {
                        ProviderName: event.request.userAttributes['cognito:identity_providers'],
                        ProviderAttributeName: 'Cognito_Subject',
                        ProviderAttributeValue: event.request.userAttributes.sub
                    }
                }));
                
                console.log('Successfully linked accounts');
                
                // Prevent creating duplicate user
                throw new Error('User account already exists. Please sign in with your existing credentials.');
                
            } catch (getUserError) {
                if (getUserError.name === 'UserNotFoundException') {
                    console.log('No existing user found, allowing signup');
                    // Allow normal signup process
                } else {
                    console.error('Error during account linking:', getUserError);
                    throw getUserError;
                }
            }
        }
        
        return event;
        
    } catch (error) {
        console.error('Pre-signup trigger error:', error);
        throw error;
    }
};