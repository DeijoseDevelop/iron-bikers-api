import { IsEnum, IsNumber, IsOptional, IsString, IsUUID } from 'class-validator';

export enum AlertType {
    PINCHAZO = 'pinchazo',
    SIN_GASOLINA = 'sin-gasolina',
    FALLA_MECANICA = 'falla-mecanica',
    ACCIDENTE = 'accidente',
    MEDICA = 'medica',
    OTRO = 'otro',
}

export class CreateSosDto {
    @IsEnum(AlertType)
    type!: AlertType;

    @IsOptional()
    @IsUUID()
    event_id?: string;

    @IsNumber()
    lat!: number;

    @IsNumber()
    lng!: number;

    @IsOptional()
    @IsString()
    description?: string;
}
